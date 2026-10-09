select
    {{ jfield('payload', 'run_id', 'bigint') }}                 as run_id,
    {{ jfield('payload', 'run_attempt', 'integer') }}           as run_attempt,
    {{ jfield('payload', 'job_id', 'bigint') }}                 as job_id,
    {{ jfield('payload', 'number', 'integer') }}                as step_number,
    {{ jfield('payload', 'name') }}                             as step_name,
    {{ jfield('payload', 'conclusion') }}                       as conclusion,
    {{ utc_ts(jfield('payload', 'started_at')) }}               as started_at,
    {{ utc_ts(jfield('payload', 'completed_at')) }}             as completed_at
from {{ source('raw_github', 'job_steps') }}
