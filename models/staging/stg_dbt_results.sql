select
    {{ jfield('payload', 'build_file') }}                       as build_file,
    {{ utc_ts(jfield('payload', 'generated_at')) }}             as generated_at,
    {{ jfield('payload', 'elapsed_time', 'double') }}           as build_seconds,
    {{ jfield('payload', 'unique_id') }}                        as unique_id,
    split_part({{ jfield('payload', 'unique_id') }}, '.', 1)    as resource_type,
    {{ jfield('payload', 'status') }}                           as status,
    {{ jfield('payload', 'execution_time', 'double') }}         as execution_seconds,
    {{ jfield('payload', 'failures', 'integer') }}              as failures,
    {{ jfield('payload', 'message') }}                          as message
from {{ source('raw_cloverleaf', 'dbt_results') }}
