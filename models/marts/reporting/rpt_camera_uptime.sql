-- Per camera: share of captures with a live picture, and where it stands now.
with n as (select extracted_at from {{ ref('stg_extract') }}),
c as (select * from {{ ref('fct_camera_captures') }}),
latest as (
    select camera_id, feed_state as current_state, captured_at as last_capture_at
    from c qualify row_number() over (partition by camera_id order by captured_at desc) = 1
)
select
    c.camera_id,
    max(cam.camera_name) as camera_name,
    max(cam.corridor)    as corridor,
    max(cam.route)       as route,
    l.current_state,
    max(case when c.captured_at = l.last_capture_at then cast(c.is_dark as integer) end) = 1 as currently_dark,
    l.last_capture_at,
    max(case when c.feed_state = 'live' then c.captured_at end)                                   as last_live_at,
    avg(case when c.captured_at > {{ hours_before('n.extracted_at', 24) }} then case when c.feed_state = 'live' then 1.0 else 0.0 end end) as uptime_24h,
    avg(case when c.captured_at > {{ hours_before('n.extracted_at', 168) }} then case when c.feed_state = 'live' then 1.0 else 0.0 end end) as uptime_7d,
    sum(case when c.feed_state = 'offline' then 1 else 0 end)    as offline_captures,
    sum(case when c.feed_state = 'unreadable' then 1 else 0 end) as unreadable_captures,
    sum(case when c.feed_state = 'no_picture' then 1 else 0 end) as no_picture_captures,
    sum(case when c.feed_state = 'frozen' then 1 else 0 end)     as frozen_captures,
    count(*)                                                     as captures,
    avg(c.read_seconds)                                          as avg_read_seconds,
    avg(c.analysis_seconds)                                      as avg_analysis_seconds
from c cross join n
join latest l on l.camera_id = c.camera_id
left join {{ ref('stg_cameras') }} cam on cam.camera_id = c.camera_id
group by c.camera_id, l.current_state, l.last_capture_at
