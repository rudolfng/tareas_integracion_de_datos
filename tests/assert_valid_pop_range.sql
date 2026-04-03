-- La probabilidad de precipitación (pop) en OpenWeather debe estar entre 0 y 1
select
    dt_unix,
    probability_of_precipitation
from {{ ref('stg_forecast') }}
where probability_of_precipitation < 0 or probability_of_precipitation > 1
