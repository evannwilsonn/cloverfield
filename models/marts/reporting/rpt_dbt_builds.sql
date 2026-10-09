select *, {{ to_pacific('generated_at') }} as generated_at_local from {{ ref('fct_dbt_builds') }}
