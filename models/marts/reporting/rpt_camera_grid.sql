-- Camera x collector run for the latest 48 runs (about a day): the uptime strip on the dashboard.
with runs as (
    select collector_run_id, min(captured_at) as run_at,
           row_number() over (order by min(captured_at) desc) as recency
    from {{ ref('fct_camera_captures') }} group by 1
)
select c.camera_id, r.collector_run_id, r.run_at, {{ to_pacific('r.run_at') }} as run_at_local, r.recency,
       c.feed_state, c.is_dark
from {{ ref('fct_camera_captures') }} c
join runs r on r.collector_run_id = c.collector_run_id
where r.recency <= 48
