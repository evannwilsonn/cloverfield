-- The latest 200 runs of each monitored workflow, for the run log.
select * from {{ ref('fct_workflow_runs') }}
qualify row_number() over (partition by workflow_file order by created_at desc) <= 200
