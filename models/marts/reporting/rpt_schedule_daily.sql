-- Per Pacific day: how reliably GitHub ran the 30-minute collector, and how it performed.
with s as (
    select local_date,
           count(*) as slots,
           sum(case when slot_outcome = 'on_time' then 1 else 0 end) as on_time,
           sum(case when slot_outcome = 'late' then 1 else 0 end) as late,
           sum(case when slot_outcome = 'missed' then 1 else 0 end) as missed,
           sum(case when slot_outcome = 'pending' then 1 else 0 end) as pending,
           median(start_delay_minutes) as median_delay_minutes,
           {{ pctl('start_delay_minutes', 0.95) }} as p95_delay_minutes
    from {{ ref('fct_schedule_slots') }} where workflow_file = 'collect.yml' group by 1
),
r as (
    select local_date, count(*) as runs,
           sum(case when conclusion = 'success' then 1 else 0 end) as succeeded,
           sum(case when conclusion = 'failure' then 1 else 0 end) as failed,
           sum(case when event <> 'schedule' then 1 else 0 end) as manual_runs,
           median(duration_minutes) as median_duration_minutes,
           {{ pctl('duration_minutes', 0.95) }} as p95_duration_minutes
    from {{ ref('fct_workflow_runs') }} where workflow_file = 'collect.yml' and status = 'completed' group by 1
)
select coalesce(s.local_date, r.local_date) as local_date, s.slots, s.on_time, s.late, s.missed, s.pending,
       s.median_delay_minutes, s.p95_delay_minutes, r.runs, r.succeeded, r.failed, r.manual_runs,
       r.median_duration_minutes, r.p95_duration_minutes
from s full outer join r on r.local_date = s.local_date
