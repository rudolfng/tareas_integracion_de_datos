-- Las filas que devuelve son las que fallan el test
select
    fecha,
    ubicacion,
    temp_maxima,
    temp_minima
from {{ ref('mart_clima_obt') }}
where temp_maxima < temp_minima
