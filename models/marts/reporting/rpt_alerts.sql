-- Alerts that are firing right now (as of the extract). Rules: seeds/alert_rules.csv, thresholds: dbt vars.
with now_ as (select extracted_at from {{ ref('stg_extract') }}),
last_capture as (select max(captured_at) as at from {{ ref('fct_camera_captures') }}),
stale as (
    select 'data_stale' as alert_id, 'Cloverleaf collector' as subject, l.at as since,
           'Last capture ' || cast(round({{ minutes_between('l.at', 'n.extracted_at') }}) as varchar) || ' minutes ago' as detail
    from last_capture l cross join now_ n
    where {{ minutes_between('l.at', 'n.extracted_at') }} > {{ var('stale_after_minutes') }}
),
failing as (
    select 'collect_failing', 'collect.yml', min(r.created_at),
           cast(count(*) as varchar) || ' failed runs in the last {{ var("failed_runs_window_hours") }} hours'
    from {{ ref('fct_workflow_runs') }} r cross join now_ n
    where r.workflow_file = 'collect.yml' and r.conclusion = 'failure'
      and r.created_at > {{ hours_before('n.extracted_at', var('failed_runs_window_hours')) }}
    having count(*) >= {{ var('failed_runs_threshold') }}
),
latest_build as (
    select * from {{ ref('fct_dbt_builds') }} qualify row_number() over (order by generated_at desc) = 1
),
build as (
    select 'build_failed', 'Cloverleaf dbt build', generated_at,
           cast(tests_failed as varchar) || ' failing tests, ' || cast(model_errors as varchar) || ' model errors'
               || case when accuracy_gate in ('fail', 'error') then ' (detection accuracy gate failed)' else '' end
    from latest_build where tests_failed > 0 or model_errors > 0
),
cam_last_live as (
    select camera_id, max(case when feed_state = 'live' then captured_at end) as last_live
    from {{ ref('fct_camera_captures') }} group by 1
),
cam_streak as (
    select c.camera_id, count(*) as captures_without_picture, min(c.captured_at) as since, max(c.feed_state) as state
    from {{ ref('fct_camera_captures') }} c
    join cam_last_live l on l.camera_id = c.camera_id
    where l.last_live is null or c.captured_at > l.last_live
    group by 1
),
cameras as (
    select 'camera_down', camera_id, since,
           cast(captures_without_picture as varchar) || ' captures in a row without a live picture (latest: ' || state || ')'
    from cam_streak where captures_without_picture >= {{ var('camera_down_after_captures') }}
),
gaps as (
    select 'schedule_gaps', 'collect.yml', min(s.slot_at),
           cast(count(*) as varchar) || ' scheduled runs missed in the last {{ var("missed_slots_window_hours") }} hours'
    from {{ ref('fct_schedule_slots') }} s cross join now_ n
    where s.workflow_file = 'collect.yml' and s.slot_outcome = 'missed'
      and s.slot_at > {{ hours_before('n.extracted_at', var('missed_slots_window_hours')) }}
    having count(*) >= {{ var('missed_slots_threshold') }}
),
firing as (
    select * from stale union all select * from failing union all select * from build
    union all select * from cameras union all select * from gaps
)
select f.alert_id, r.severity, r.alert_name, f.subject, f.since, {{ to_pacific('f.since') }} as since_local, f.detail
from firing f
join {{ ref('alert_rules') }} r on r.alert_id = f.alert_id
