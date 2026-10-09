"""
Extract everything Cloverfield monitors about Cloverleaf, as it is, into data/raw/.

  github/runs.json          the latest workflow runs of every monitored workflow (GitHub REST API)
  github/jobs/<run>.json    job and step timings for each finished run (fetched once, then kept)
  cloverleaf/captures/...   the collector's per-camera output (Cloverleaf's `data` branch)
  cloverleaf/ops/dbt/...    run_results.json from each of Cloverleaf's daily dbt builds
  cloverleaf/cameras.csv    the camera list (names, corridors) from Cloverleaf's main branch
  _extract.json             when this extract ran, what it read, and a SHA-256 of every file

Reads public data only. GITHUB_TOKEN (set automatically in Actions) raises the API rate limit.

    python ingest/extract.py
"""
from __future__ import annotations

import csv
import hashlib
import io
import json
import os
import subprocess
import tarfile
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
API = "https://api.github.com"


def gh(path: str) -> dict:
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "cloverfield-monitor",
               "X-GitHub-Api-Version": "2022-11-28"}
    if os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {os.environ['GITHUB_TOKEN']}"
    with urllib.request.urlopen(urllib.request.Request(API + path, headers=headers), timeout=30) as r:
        return json.load(r)


def fetch_runs(repo: str, workflow: str, pages: int = 5) -> list[dict]:
    runs = []
    for page in range(1, pages + 1):
        batch = gh(f"/repos/{repo}/actions/workflows/{workflow}/runs?per_page=100&page={page}")["workflow_runs"]
        runs += batch
        if len(batch) < 100:
            break
    return runs


def fetch_data_branch(repo: str) -> int:
    """Copy captures/ and ops/ from the monitored repo's data branch (no full clone)."""
    work = ROOT / "data" / "_cloverleaf.git"
    if not work.exists():
        subprocess.run(["git", "init", "--quiet", "--bare", str(work)], check=True)
    subprocess.run(["git", "--git-dir", str(work), "fetch", "--quiet", "--depth", "1", f"https://github.com/{repo}", "data"], check=True)
    paths = subprocess.run(["git", "--git-dir", str(work), "ls-tree", "--name-only", "FETCH_HEAD"], check=True,
                           capture_output=True, text=True).stdout.split()
    keep = [p for p in ("captures", "ops") if p in paths]
    tar = subprocess.run(["git", "--git-dir", str(work), "archive", "FETCH_HEAD", *keep], check=True, capture_output=True).stdout
    dest = RAW / "cloverleaf"
    with tarfile.open(fileobj=io.BytesIO(tar)) as t:
        t.extractall(dest, filter="data")
    return len(list(dest.rglob("*.json*")))


def main() -> None:
    started = datetime.now(timezone.utc).replace(microsecond=0)
    monitored = list(csv.DictReader(open(ROOT / "seeds" / "monitored_workflows.csv", encoding="utf-8")))
    repo = monitored[0]["repo"]
    (RAW / "github" / "jobs").mkdir(parents=True, exist_ok=True)

    runs = []
    for w in monitored:
        runs += fetch_runs(w["repo"], w["workflow_file"])
    (RAW / "github" / "runs.json").write_text(json.dumps(runs), encoding="utf-8")

    new_jobs = 0
    for r in runs:
        f = RAW / "github" / "jobs" / f"{r['id']}_{r['run_attempt']}.json"
        if r["status"] == "completed" and not f.exists():
            jobs = gh(f"/repos/{repo}/actions/runs/{r['id']}/attempts/{r['run_attempt']}/jobs")["jobs"]
            f.write_text(json.dumps({"run_id": r["id"], "run_attempt": r["run_attempt"], "jobs": jobs}), encoding="utf-8")
            new_jobs += 1

    n_files = fetch_data_branch(repo)
    # camera names and corridors live in the monitored repo's seed file
    with urllib.request.urlopen(f"https://raw.githubusercontent.com/{repo}/main/seeds/cameras.csv", timeout=30) as r:
        (RAW / "cloverleaf" / "cameras.csv").write_bytes(r.read())

    files = sorted(p for p in RAW.rglob("*") if p.is_file() and p.name != "_extract.json")
    manifest = {
        "extracted_at": started.isoformat(),
        "monitored_repo": repo,
        "workflow_runs": len(runs),
        "job_files_fetched_now": new_jobs,
        "files": [{"path": p.relative_to(RAW).as_posix(), "bytes": p.stat().st_size,
                   "sha256": hashlib.sha256(p.read_bytes()).hexdigest()} for p in files],
    }
    (RAW / "_extract.json").write_text(json.dumps(manifest, indent=1), encoding="utf-8")
    print(f"{len(runs)} workflow runs ({new_jobs} new job files), {n_files} Cloverleaf data files, "
          f"{len(files)} files in data/raw")


if __name__ == "__main__":
    main()
