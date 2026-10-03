select *
from {{ source('raw', 'orders') }}
where upper(trim(category)) = 'HOME'
