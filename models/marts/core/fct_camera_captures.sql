select
    collector_run_id, github_run_id, camera_id, collector_started_at, captured_at,
    {{ to_pacific('captured_at') }} as captured_at_local,
    feed_state, is_dark, stream_error, read_seconds, analysis_seconds, runner, code_version
from {{ ref('int_captures__state') }}
