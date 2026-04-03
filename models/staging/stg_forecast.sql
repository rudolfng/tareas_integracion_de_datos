/*
    MODELO: stg_forecast
    CAPA: Staging
    DESCRIPCIÓN: Limpieza inicial y extracción de datos anidados de OpenWeather.
    NOTAS: 
    - Se asume que los datos vienen en sistema métrico (Celsius, m/s).
*/

with source as (
    -- Fuente de Airbyte en MotherDuck
    select * from {{ source('airbyte_raw', 'forecast') }}
),

renamed as (
    select
        dt as dt_unix,

        /* 
           EXTRACCIÓN DE MÉTRICAS PRINCIPALES
           Accedemos al objeto 'main' de OpenWeather. 
           Casteamos a DECIMAL/INTEGER para asegurar tipado correcto en capas superiores.
        */
        (main->>'$.temp')::DECIMAL as temp_celsius,
        (main->>'$.feels_like')::DECIMAL as feels_like_celsius,
        (main->>'$.temp_max')::DECIMAL as temp_max_celsius,
        (main->>'$.temp_min')::DECIMAL as temp_min_celsius,
        (main->>'$.humidity')::INTEGER as humidity,

        /* 
           DATOS CLIMÁTICOS (Condiciones)
           'weather' es una lista JSON. Extraemos el primer elemento [0] 
           para obtener la condición principal y su descripción.
        */
        weather->0->>'$.main' as weather_main,
        weather->0->>'$.description' as weather_description,

        -- Velocidad del viento (Metros por segundo por units=metric)
        (wind->>'$.speed')::DECIMAL as wind_speed_ms,

        dt_txt,
        ubicacion,
        pop as probability_of_precipitation,
        _airbyte_extracted_at
    from source
)

select * from renamed
