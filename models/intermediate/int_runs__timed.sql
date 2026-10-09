-- Each workflow run with its schedule slot, start delay and duration.
with jobs as (
    select run_id, run_attempt, min(started_at) as job_started_at, max(completed_at) as job_completed_at
    from {{ ref('stg_jobs') }} group by 1, 2
)
select
    r.*,
    w.period_seconds,
    w.on_time_minutes,
    w.max_duration_minutes,
    case when r.event = 'schedule' then {{ slot_of('r.created_at', 'w.period_seconds', 'w.offset_seconds') }} end as slot_at,
    case when r.event = 'schedule'
         then {{ minutes_between(slot_of('r.created_at', 'w.period_seconds', 'w.offset_seconds'), 'r.created_at') }} end as start_delay_minutes,
    j.job_started_at,
    j.job_completed_at,
    {{ minutes_between('coalesce(j.job_started_at, r.run_started_at)', 'coalesce(j.job_completed_at, r.updated_at)') }} as duration_minutes
from {{ ref('stg_workflow_runs') }} r
join {{ ref('monitored_workflows') }} w on w.workflow_file = r.workflow_file
left join jobs j on j.run_id = r.run_id and j.run_attempt = r.run_attempt
