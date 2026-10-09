-- Every scheduled run must land in a generated slot; if not, the slot maths or the seed's schedule is wrong.
select r.run_id, r.slot_at
from {{ ref('int_runs__timed') }} r
left join {{ ref('fct_schedule_slots') }} s on s.workflow_file = r.workflow_file and s.slot_at = r.slot_at
where r.event = 'schedule' and s.slot_at is null
