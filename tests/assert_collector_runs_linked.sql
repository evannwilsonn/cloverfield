-- Every capture written by GitHub Actions should trace back to a workflow run Cloverfield knows about.
-- (Runs older than the API window are allowed to fall out; only the last 3 days are checked.)
select c.collector_run_id, c.github_run_id
from {{ ref('fct_camera_captures') }} c
cross join {{ ref('stg_extract') }} n
left join {{ ref('stg_workflow_runs') }} r on r.run_id = c.github_run_id
where c.github_run_id is not null and r.run_id is null
  and c.captured_at > {{ hours_before('n.extracted_at', 72) }}
