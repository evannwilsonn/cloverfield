"""
Export the reporting marts to dashboard/data.json for the status page.

    python dashboard/export_data.py                  # from the local DuckDB warehouse
    python dashboard/export_data.py --target snowflake
"""
from __future__ import annotations

import argparse
import json
import os
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TABLES = {
    "status": "select * from reporting.rpt_status_now",
    "slo": "select * from reporting.rpt_slo order by slo_id, window_name",
    "alerts": "select * from reporting.rpt_alerts order by severity, since",
    "schedule_daily": "select * from reporting.rpt_schedule_daily order by local_date",
    "slots": "select workflow_file, slot_at, slot_at_local, slot_outcome, start_delay_minutes, conclusion, duration_minutes "
             "from core.fct_schedule_slots order by slot_at",
    "runs": "select * from reporting.rpt_runs order by created_at",
    "cameras": "select * from reporting.rpt_camera_uptime order by camera_id",
    "grid": "select camera_id, recency, run_at_local, feed_state, is_dark from reporting.rpt_camera_grid order by camera_id, recency",
    "builds": "select * from reporting.rpt_dbt_builds order by generated_at",
    "slos_ref": "select * from reference.slos",
    "workflows": "select * from reference.monitored_workflows",
}


def clean(v):
    if isinstance(v, (datetime, date)):
        return v.isoformat()
    if isinstance(v, Decimal):
        return float(v)
    if isinstance(v, float):
        return round(v, 4)
    return v


def runner(target: str):
    if target == "snowflake":
        import snowflake.connector
        con = snowflake.connector.connect(
            account=os.environ["SNOWFLAKE_ACCOUNT"], user=os.environ["SNOWFLAKE_USER"],
            private_key_file=os.environ["SNOWFLAKE_PRIVATE_KEY_PATH"], role=os.environ.get("SNOWFLAKE_ROLE", "SYSADMIN"),
            warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "PORTFOLIO_WH"), database="CLOVERFIELD")

        def run(sql):
            cur = con.cursor()
            cur.execute(sql)
            return [c[0].lower() for c in cur.description], cur.fetchall()
        return run
    import duckdb
    con = duckdb.connect(str(ROOT / "warehouse" / "cloverfield.duckdb"), read_only=True)

    def run(sql):
        cur = con.execute(sql)
        return [c[0] for c in cur.description], cur.fetchall()
    return run


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", choices=["duckdb", "snowflake"], default="duckdb")
    args = ap.parse_args()
    run = runner(args.target)
    out = {"generated": datetime.now().isoformat(timespec="seconds"), "source": args.target}
    for key, sql in TABLES.items():
        cols, rows = run(sql)
        out[key] = [{c: clean(v) for c, v in zip(cols, r)} for r in rows]
    path = ROOT / "dashboard" / "data.json"
    path.write_text(json.dumps(out, separators=(",", ":")), encoding="utf-8")
    s = out["status"][0] if out["status"] else {}
    print(f"Wrote {path.relative_to(ROOT)} ({path.stat().st_size // 1024} KB): overall {s.get('overall')}, "
          f"{len(out['alerts'])} alerts, {len(out['runs'])} runs, from {args.target}")


if __name__ == "__main__":
    main()
