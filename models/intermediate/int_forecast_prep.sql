/*
    MODELO: int_forecast_prep
    CAPA: Intermediate
    DESCRIPCIÓN: Estandarización de tipos de datos, parsing de fechas y limpieza de nulos.
    DEPENDENCIAS: stg_forecast
*/

with staging as (
    -- Referencia al modelo de staging previo
    select * from {{ ref('stg_forecast') }}
),

transformed as (
    select
        /* 
           MANEJO DE TIEMPO
           Parseamos la cadena dt_txt al tipo TIMESTAMP de DuckDB 
           y generamos una columna 'fecha' pura para agrupaciones.
        */
        strptime(dt_txt, '%Y-%m-%d %H:%M:%S') as fecha_hora,
        cast(strptime(dt_txt, '%Y-%m-%d %H:%M:%S') as DATE) as fecha,
        ubicacion,

        /* 
           MÉTRICAS CLIMÁTICAS
           Redondeo preventivo a 2 decimales para facilitar la lectura.
        */
        round(temp_celsius, 2) as temp_celsius,
        round(temp_max_celsius, 2) as temp_max_celsius,
        round(temp_min_celsius, 2) as temp_min_celsius,
        
        humidity,
        weather_main as condicion_principal,
        weather_description as descripcion,
        wind_speed_ms,
        probability_of_precipitation
    from staging
)

select * from transformed
