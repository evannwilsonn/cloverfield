-- Cloverleaf's collector output, only the fields that describe whether the pipeline worked.
select
    {{ jfield('payload', 'run_id') }}                           as collector_run_id,
    {{ jfield('payload', 'github_run_id', 'bigint') }}          as github_run_id,
    {{ jfield('payload', 'camera_id') }}                        as camera_id,
    {{ utc_ts(jfield('payload', 'run_started_at')) }}           as collector_started_at,
    {{ utc_ts(jfield('payload', 'captured_at')) }}              as captured_at,
    {{ jfield('payload', 'status') }}                           as stream_status,
    {{ jfield('payload', 'error') }}                            as stream_error,
    {{ jfield('payload', 'runner') }}                           as runner,
    {{ jfield('payload', 'code_version') }}                     as code_version,
    {{ jfield('payload', 'brightness', 'double') }}             as brightness,
    {{ jfield('payload', 'contrast', 'double') }}               as contrast,
    {{ jfield('payload', 'motion', 'double') }}                 as motion,
    {{ jfield('payload', 'sun_elevation', 'double') }}          as sun_elevation,
    {{ jfield('payload', 'read_seconds', 'double') }}           as read_seconds,
    {{ jfield('payload', 'analysis_seconds', 'double') }}       as analysis_seconds,
    {{ jfield('payload', 'frames_analyzed', 'integer') }}       as frames_analyzed,
    _source_file
from {{ source('raw_cloverleaf', 'captures') }}
