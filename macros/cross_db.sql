{#- Cross-database helpers: every model runs unchanged on DuckDB (local) and Snowflake. -#}

{% macro jfield(col, path, type='varchar') -%}{{ return(adapter.dispatch('jfield')(col, path, type)) }}{%- endmacro %}
{% macro duckdb__jfield(col, path, type) -%}try_cast(json_extract_string({{ col }}, '$.{{ path }}') as {{ type }}){%- endmacro %}
{% macro snowflake__jfield(col, path, type) -%}try_cast({{ col }}:{{ path }}::varchar as {{ type }}){%- endmacro %}

{# GitHub, the collector and dbt all write UTC ISO-8601; keep naive UTC timestamps #}
{% macro utc_ts(expr) -%}cast(replace(substr({{ expr }}, 1, 19), 'T', ' ') as timestamp){%- endmacro %}

{% macro to_pacific(ts) -%}{{ return(adapter.dispatch('to_pacific')(ts)) }}{%- endmacro %}
{% macro duckdb__to_pacific(ts) -%}cast(timezone('America/Los_Angeles', timezone('UTC', {{ ts }})) as timestamp){%- endmacro %}
{% macro snowflake__to_pacific(ts) -%}convert_timezone('UTC', 'America/Los_Angeles', {{ ts }}){%- endmacro %}

{% macro epoch(ts) -%}{{ return(adapter.dispatch('epoch')(ts)) }}{%- endmacro %}
{% macro duckdb__epoch(ts) -%}epoch({{ ts }}){%- endmacro %}
{% macro snowflake__epoch(ts) -%}date_part(epoch_second, {{ ts }}){%- endmacro %}

{% macro from_epoch(seconds) -%}{{ return(adapter.dispatch('from_epoch')(seconds)) }}{%- endmacro %}
{% macro duckdb__from_epoch(seconds) -%}cast(timezone('UTC', to_timestamp({{ seconds }})) as timestamp){%- endmacro %}
{% macro snowflake__from_epoch(seconds) -%}to_timestamp_ntz({{ seconds }}){%- endmacro %}

{% macro minutes_between(a, b) -%}(({{ epoch(b) }} - {{ epoch(a) }}) / 60.0){%- endmacro %}

{# the scheduled slot a timestamp belongs to: the latest offset + k * period at or before it #}
{% macro slot_of(ts, period, offset) -%}{{ from_epoch('floor((' ~ epoch(ts) ~ ' - ' ~ offset ~ ') / ' ~ period ~ ') * ' ~ period ~ ' + ' ~ offset) }}{%- endmacro %}

{% macro pctl(col, p) -%}{{ return(adapter.dispatch('pctl')(col, p)) }}{%- endmacro %}
{% macro duckdb__pctl(col, p) -%}quantile_cont({{ col }}, {{ p }}){%- endmacro %}
{% macro snowflake__pctl(col, p) -%}percentile_cont({{ p }}) within group (order by {{ col }}){%- endmacro %}

{# 0 .. 99,999 without generate_series, so it runs on both engines #}
{% macro numbers() -%}
select d1.n + 10 * d2.n + 100 * d3.n + 1000 * d4.n + 10000 * d5.n as n
from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d1(n)
cross join (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d2(n)
cross join (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d3(n)
cross join (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d4(n)
cross join (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) d5(n)
{%- endmacro %}

{% macro hours_before(ts, hours) -%}{{ return(adapter.dispatch('hours_before')(ts, hours)) }}{%- endmacro %}
{% macro duckdb__hours_before(ts, hours) -%}({{ ts }} - ({{ hours }}) * interval '1 hour'){%- endmacro %}
{% macro snowflake__hours_before(ts, hours) -%}dateadd(hour, -({{ hours }}), {{ ts }}){%- endmacro %}
