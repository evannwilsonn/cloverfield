-- Every run of a monitored workflow, with timing, what the collector delivered, and its slowest steps.
with cams as (
    select github_run_id,
           count(*)                                                  as cameras_attempted,
           sum(case when feed_state = 'live' then 1 else 0 end)      as cameras_live,
           max(captured_at)                                          as last_capture_at,
           sum(analysis_seconds)                                     as analysis_seconds
    from {{ ref('int_captures__state') }}
    where github_run_id is not null
    group by 1
),
steps as (
    select run_id, run_attempt,
        sum(case when step_name like '%pip install%' then {{ minutes_between('started_at', 'completed_at') }} end)        as install_minutes,
        sum(case when step_name = 'Record and analyse clips' then {{ minutes_between('started_at', 'completed_at') }} end) as capture_minutes,
        sum(case when step_name = 'Append to the data branch' then {{ minutes_between('started_at', 'completed_at') }} end) as push_minutes
    from {{ ref('stg_job_steps') }}
    group by 1, 2
)
select
    r.run_id, r.run_attempt, r.run_number, r.workflow_file, r.event, r.status, r.conclusion,
    r.created_at, {{ to_pacific('r.created_at') }} as created_at_local, cast({{ to_pacific('r.created_at') }} as date) as local_date,
    r.slot_at, r.start_delay_minutes, r.duration_minutes, r.max_duration_minutes,
    r.duration_minutes <= r.max_duration_minutes as finished_in_time,
    r.head_sha,
    c.cameras_attempted, c.cameras_live, c.last_capture_at, c.analysis_seconds,
    s.install_minutes, s.capture_minutes, s.push_minutes
from {{ ref('int_runs__timed') }} r
left join cams c on c.github_run_id = r.run_id
left join steps s on s.run_id = r.run_id and s.run_attempt = r.run_attempt
