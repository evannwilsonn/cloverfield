"""
Land the extract in DuckDB unchanged, one JSON payload per row (schemas raw_github, raw_cloverleaf).

  raw_github.workflow_runs      one row per workflow run
  raw_github.jobs               one row per job
  raw_github.job_steps          one row per step of each job
  raw_cloverleaf.captures       one row per camera per collector run
  raw_cloverleaf.dbt_results    one row per node in each of Cloverleaf's dbt builds
  raw_github.extract_log        when the extract ran (the "now" every age is measured from)

    python ingest/load_raw.py
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DB = ROOT / "warehouse" / "cloverfield.duckdb"


def rows_table(con, name: str, rows: list[dict], loaded_at: str) -> int:
    tmp = ROOT / "data" / f"_{name.replace('.', '_')}.jsonl"
    with open(tmp, "w", encoding="utf-8") as fh:
        for r in rows:
            fh.write(json.dumps(r) + "\n")
    con.execute(f"""create or replace table {name} as
        select json as payload, json_extract_string(json, '$._source_file') as _source_file,
               cast('{loaded_at}' as timestamp) as _loaded_at
        from read_json_objects('{tmp.as_posix()}', format = 'newline_delimited')""")
    tmp.unlink()
    return len(rows)


def main() -> None:
    manifest = json.loads((RAW / "_extract.json").read_text())
    DB.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB))
    for s in ("raw_github", "raw_cloverleaf"):
        con.execute(f"create schema if not exists {s}")
    loaded_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    runs = [{**r, "_source_file": "github/runs.json"} for r in json.loads((RAW / "github" / "runs.json").read_text())]
    jobs, steps = [], []
    for f in sorted((RAW / "github" / "jobs").glob("*.json")):
        d = json.loads(f.read_text())
        for j in d["jobs"]:
            jobs.append({**{k: v for k, v in j.items() if k != "steps"}, "run_attempt": d["run_attempt"],
                         "_source_file": f"github/jobs/{f.name}"})
            steps += [{**st, "job_id": j["id"], "run_id": j["run_id"], "run_attempt": d["run_attempt"],
                       "_source_file": f"github/jobs/{f.name}"} for st in j.get("steps") or []]
    captures = []
    for f in sorted((RAW / "cloverleaf" / "captures").rglob("*.jsonl")):
        rel = f.relative_to(RAW).as_posix()
        captures += [{**json.loads(line), "_source_file": rel} for line in open(f, encoding="utf-8") if line.strip()]
    results = []
    for f in sorted((RAW / "cloverleaf" / "ops" / "dbt").glob("*.json")) if (RAW / "cloverleaf" / "ops" / "dbt").exists() else []:
        d = json.loads(f.read_text())
        meta = {"build_file": f.name, "generated_at": d["metadata"]["generated_at"], "elapsed_time": d.get("elapsed_time"),
                "dbt_version": d["metadata"].get("dbt_version")}
        results += [{**meta, "unique_id": r["unique_id"], "status": r["status"], "execution_time": r.get("execution_time"),
                     "failures": r.get("failures"), "message": (r.get("message") or "")[:500],
                     "_source_file": f"cloverleaf/ops/dbt/{f.name}"} for r in d["results"]]
    con.execute(f"""create or replace table raw_cloverleaf.cameras as
        select *, 'cloverleaf/cameras.csv' as _source_file, cast('{loaded_at}' as timestamp) as _loaded_at
        from read_csv('{(RAW / "cloverleaf" / "cameras.csv").as_posix()}', header = true, all_varchar = true)""")
    counts = {
        "raw_github.workflow_runs": rows_table(con, "raw_github.workflow_runs", runs, loaded_at),
        "raw_github.jobs": rows_table(con, "raw_github.jobs", jobs, loaded_at),
        "raw_github.job_steps": rows_table(con, "raw_github.job_steps", steps, loaded_at),
        "raw_cloverleaf.captures": rows_table(con, "raw_cloverleaf.captures", captures, loaded_at),
        "raw_cloverleaf.cameras": con.execute("select count(*) from raw_cloverleaf.cameras").fetchone()[0],
        "raw_cloverleaf.dbt_results": rows_table(con, "raw_cloverleaf.dbt_results", results, loaded_at),
        "raw_github.extract_log": rows_table(con, "raw_github.extract_log",
                                             [{"extracted_at": manifest["extracted_at"], "files": len(manifest["files"]),
                                               "_source_file": "_extract.json"}], loaded_at),
    }
    print(f"Loaded into {DB.relative_to(ROOT)}")
    for k, v in counts.items():
        print(f"  {k:<30} {v:>7,} rows")


if __name__ == "__main__":
    main()
