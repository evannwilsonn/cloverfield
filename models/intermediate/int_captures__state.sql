-- What each camera actually delivered, in Cloverleaf's terms (same thresholds as its capture rules).
select
    c.*,
    case
        when stream_status = 'offline' then 'offline'
        when stream_status = 'error' then 'unreadable'
        when brightness < {{ var('min_brightness') }} or contrast < {{ var('min_contrast') }} then 'no_picture'
        when motion < {{ var('frozen_motion') }} then 'frozen'
        else 'live'
    end as feed_state,
    sun_elevation < 0 as is_dark
from {{ ref('stg_captures') }} c
