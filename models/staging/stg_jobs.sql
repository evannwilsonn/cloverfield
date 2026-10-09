select
    {{ jfield('payload', 'id', 'bigint') }}                     as job_id,
    {{ jfield('payload', 'run_id', 'bigint') }}                 as run_id,
    {{ jfield('payload', 'run_attempt', 'integer') }}           as run_attempt,
    {{ jfield('payload', 'name') }}                             as job_name,
    {{ jfield('payload', 'conclusion') }}                       as conclusion,
    {{ jfield('payload', 'runner_name') }}                      as runner_name,
    {{ utc_ts(jfield('payload', 'started_at')) }}               as started_at,
    {{ utc_ts(jfield('payload', 'completed_at')) }}             as completed_at
from {{ source('raw_github', 'jobs') }}
