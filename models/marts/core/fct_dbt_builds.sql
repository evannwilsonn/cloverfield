-- One row per Cloverleaf dbt build that saved its results.
select
    build_file,
    max(generated_at)                                                                       as generated_at,
    max(build_seconds)                                                                      as build_seconds,
    sum(case when resource_type = 'model' then 1 else 0 end)                                as models,
    sum(case when resource_type = 'model' and status = 'error' then 1 else 0 end)           as model_errors,
    sum(case when resource_type = 'test' then 1 else 0 end)                                 as tests,
    sum(case when resource_type = 'test' and status = 'pass' then 1 else 0 end)             as tests_passed,
    sum(case when resource_type = 'test' and status = 'warn' then 1 else 0 end)             as tests_warned,
    sum(case when resource_type = 'test' and status in ('fail', 'error') then 1 else 0 end) as tests_failed,
    max(case when unique_id like '%assert_daylight_detection_accuracy%' then status end)    as accuracy_gate
from {{ ref('stg_dbt_results') }}
group by 1
