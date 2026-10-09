-- One row per scheduled slot: did a run start for it, and how late.
with sched as (
    select workflow_file, slot_at, run_id, conclusion, start_delay_minutes, duration_minutes,
           row_number() over (partition by workflow_file, slot_at order by created_at) as rn
    from {{ ref('int_runs__timed') }}
    where event = 'schedule'
)
select
    s.workflow_file,
    s.slot_at,
    {{ to_pacific('s.slot_at') }}                         as slot_at_local,
    cast({{ to_pacific('s.slot_at') }} as date)           as local_date,
    r.run_id,
    r.conclusion,
    r.start_delay_minutes,
    r.duration_minutes,
    case
        when r.run_id is not null and r.start_delay_minutes <= s.on_time_minutes then 'on_time'
        when r.run_id is not null then 'late'
        when {{ minutes_between('s.slot_at', 's.extracted_at') }} <= s.on_time_minutes then 'pending'
        else 'missed'
    end as slot_outcome
from {{ ref('int_schedule_slots') }} s
left join sched r on r.workflow_file = s.workflow_file and r.slot_at = s.slot_at and r.rn = 1
