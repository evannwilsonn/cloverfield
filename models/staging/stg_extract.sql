select max({{ utc_ts(jfield('payload', 'extracted_at')) }}) as extracted_at
from {{ source('raw_github', 'extract_log') }}
