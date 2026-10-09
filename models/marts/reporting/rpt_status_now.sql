-- The one-line answer to "is Cloverleaf working right now?"
with n as (select extracted_at from {{ ref('stg_extract') }}),
last_run as (
    select * from {{ ref('fct_workflow_runs') }} where workflow_file = 'collect.yml'
    qualify row_number() over (order by created_at desc) = 1
),
last_build as (
    select * from {{ ref('fct_dbt_builds') }} qualify row_number() over (order by generated_at desc) = 1
),
latest_caps as (
    select * from {{ ref('fct_camera_captures') }}
    where collector_run_id = (select collector_run_id from {{ ref('fct_camera_captures') }}
                              order by captured_at desc limit 1)
),
alerts as (
    select sum(case when severity = 'critical' then 1 else 0 end) as critical, count(*) as total from {{ ref('rpt_alerts') }}
)
select
    n.extracted_at,
    {{ to_pacific('n.extracted_at') }}                                                  as extracted_at_local,
    (select max(captured_at) from {{ ref('fct_camera_captures') }})                     as last_capture_at,
    {{ minutes_between('(select max(captured_at) from ' ~ ref('fct_camera_captures') ~ ')', 'n.extracted_at') }} as minutes_since_capture,
    lr.run_id as last_collect_run_id, lr.conclusion as last_collect_conclusion, lr.created_at_local as last_collect_at_local,
    lr.duration_minutes as last_collect_minutes,
    (select count(*) from latest_caps)                                                  as cameras_in_last_run,
    (select sum(case when feed_state = 'live' then 1 else 0 end) from latest_caps)      as cameras_live_in_last_run,
    lb.generated_at as last_build_at, lb.tests_passed as last_build_tests_passed, lb.tests as last_build_tests,
    lb.tests_failed as last_build_tests_failed,
    coalesce(a.critical, 0) as critical_alerts, coalesce(a.total, 0) as alerts,
    case when coalesce(a.critical, 0) > 0 then 'down' when coalesce(a.total, 0) > 0 then 'degraded' else 'healthy' end as overall
from n
left join last_run lr on true
left join last_build lb on true
cross join alerts a
