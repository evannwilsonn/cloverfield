-- Each service-level objective over the last 24 hours and the last 7 days, against its target.
with now_ as (select extracted_at from {{ ref('stg_extract') }}),
windows as (
    select '24h' as window_name, 24 as hours union all select '7d', 168
),
slots as (
    select w.window_name,
           sum(case when s.slot_outcome = 'on_time' then 1 else 0 end) as good,
           sum(case when s.slot_outcome <> 'pending' then 1 else 0 end) as total
    from windows w cross join now_ n
    join {{ ref('fct_schedule_slots') }} s on s.workflow_file = 'collect.yml'
        and s.slot_at > {{ hours_before('n.extracted_at', 'w.hours') }}
    group by 1
),
runs as (
    select w.window_name,
           sum(case when r.conclusion = 'success' then 1 else 0 end)  as succeeded,
           sum(case when r.finished_in_time then 1 else 0 end)        as fast,
           count(*)                                                   as total
    from windows w cross join now_ n
    join {{ ref('fct_workflow_runs') }} r on r.workflow_file = 'collect.yml' and r.status = 'completed'
        and r.created_at > {{ hours_before('n.extracted_at', 'w.hours') }}
    group by 1
),
caps as (
    select w.window_name,
           sum(case when c.feed_state = 'live' then 1 else 0 end) as good, count(*) as total
    from windows w cross join now_ n
    join {{ ref('fct_camera_captures') }} c on c.captured_at > {{ hours_before('n.extracted_at', 'w.hours') }}
    group by 1
),
hours as (
    select w.window_name,
           count(distinct case when c.feed_state = 'live' then date_trunc('hour', c.captured_at) end) as good,
           -- hours since monitoring began, capped at the window
           least(w.hours, ceil({{ minutes_between('(select min(captured_at) from ' ~ ref('fct_camera_captures') ~ ')', 'n.extracted_at') }} / 60.0)) as total
    from windows w cross join now_ n
    left join {{ ref('fct_camera_captures') }} c on c.captured_at > {{ hours_before('n.extracted_at', 'w.hours') }}
    group by w.window_name, w.hours, n.extracted_at
),
v as (
    select window_name, 'collect_on_time' as slo_id, good * 1.0 / nullif(total, 0) as value, total as events from slots
    union all select window_name, 'collect_success', succeeded * 1.0 / nullif(total, 0), total from runs
    union all select window_name, 'collect_fast', fast * 1.0 / nullif(total, 0), total from runs
    union all select window_name, 'camera_uptime', good * 1.0 / nullif(total, 0), total from caps
    union all select window_name, 'data_fresh', least(1.0, good * 1.0 / nullif(total, 0)), total from hours
)
select s.slo_id, s.slo_name, s.description, s.target, w.window_name,
       v.value, coalesce(v.events, 0) as events,
       case when v.value is null then 'no data' when v.value >= s.target then 'met' else 'missed' end as status
from {{ ref('slos') }} s
cross join windows w
left join v on v.slo_id = s.slo_id and v.window_name = w.window_name
