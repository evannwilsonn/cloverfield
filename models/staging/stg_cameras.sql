select camera_id, camera_name, route, direction, corridor, county
from {{ source('raw_cloverleaf', 'cameras') }}
