select
    {{ jfield('payload', 'id', 'bigint') }}                     as run_id,
    {{ jfield('payload', 'run_attempt', 'integer') }}           as run_attempt,
    {{ jfield('payload', 'run_number', 'integer') }}            as run_number,
    regexp_replace({{ jfield('payload', 'path') }}, '^.*/', '')  as workflow_file,
    {{ jfield('payload', 'event') }}                            as event,
    {{ jfield('payload', 'status') }}                           as status,
    {{ jfield('payload', 'conclusion') }}                       as conclusion,
    {{ utc_ts(jfield('payload', 'created_at')) }}               as created_at,
    {{ utc_ts(jfield('payload', 'run_started_at')) }}           as run_started_at,
    {{ utc_ts(jfield('payload', 'updated_at')) }}               as updated_at,
    {{ jfield('payload', 'head_sha') }}                         as head_sha
from {{ source('raw_github', 'workflow_runs') }}
