/*
    MODELO: mart_clima_obt
    CAPA: Marts
    TIPO: One Big Table
    DESCRIPCIÓN: Tabla maestra de clima para consumo, 
                 agrupa datos por ubicación y fecha para mostrar métricas diarias.
*/

{{ config(
    materialized='table'
) }}

with forecast_prep as (
    -- Fuente desde la capa intermediate
    select * from {{ ref('int_forecast_prep') }}
),

final_metrics as (
    select
        /* 
           DIMENSIONES DE AGRUPACIÓN
           Permite filtrar por ciudad y por día calendario.
        */
        ubicacion,
        fecha,

        -- MÉTRICAS AGREGADAS
        count(*) as registros_dia,
        round(max(temp_max_celsius), 2) as temp_maxima,
        round(min(temp_min_celsius), 2) as temp_minima,
        round(avg(humidity), 2) as humedad_promedio,
        
        /* 
           CÁLCULO DE CONDICIÓN PREDOMINANTE
           Utilizamos la función mode() de DuckDB para obtener el valor 
           más frecuente de la condición climática en el día.
        */
        mode(condicion_principal) as condicion_predominante,
        
        -- Probabilidad de lluvia promedio en el día
        round(avg(probability_of_precipitation), 4) as probabilidad_precipitacion_avg
    from forecast_prep
    group by 1, 2
)

/* 
   SALIDA FINAL
   Ordenamos por fecha descendente para que muestre lo más reciente primero.
*/
select * from final_metrics
order by fecha desc, ubicacion
