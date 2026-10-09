-- Every slot each monitored workflow was scheduled for, from when its schedule went live up to the extract.
with wf as (
    select w.workflow_file, w.period_seconds, w.offset_seconds, w.on_time_minutes,
           cast(w.schedule_live_from as timestamp) as live_from, e.extracted_at
    from {{ ref('monitored_workflows') }} w
    cross join {{ ref('stg_extract') }} e
),
bounds as (
    select *,
        -- the first slot strictly after the schedule went live
        {{ epoch(slot_of('live_from', 'period_seconds', 'offset_seconds')) }} + period_seconds as first_slot_epoch,
        {{ epoch(slot_of('extracted_at', 'period_seconds', 'offset_seconds')) }} as last_slot_epoch
    from wf
),
nums as ({{ numbers() }})
select
    b.workflow_file,
    {{ from_epoch('b.first_slot_epoch + n.n * b.period_seconds') }} as slot_at,
    b.on_time_minutes,
    b.extracted_at
from bounds b
join nums n on b.first_slot_epoch + n.n * b.period_seconds <= b.last_slot_epoch
