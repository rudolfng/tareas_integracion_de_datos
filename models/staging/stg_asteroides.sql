/*
    MODELO: stg_asteroides
    CAPA: Staging
    DESCRIPCIÓN: Extracción de datos de asteroides desde el API NeoWs de la NASA.
    NOTAS: 
    - Extraemos el diámetro estimado en Kilómetros (Min/Max).
    - Se mapean IDs únicos y banderas de riesgo (is_potentially_hazardous).
*/

with source as (
    -- Fuente de Airbyte en MotherDuck
    select * from {{ source('airbyte_raw', 'asteroides') }}
),

renamed as (
    select
        id as asteroide_id,
        name as nombre,
        designation,
        is_potentially_hazardous_asteroid as es_peligroso,

        /* 
           DIMENSIONES FÍSICAS
           Acceso profundo a JSON: estimated_diameter -> kilometers -> [min/max]
           Casteamos a DECIMAL para análisis numérico posterior.
        */
        (estimated_diameter->'$.kilometers'->>'$.estimated_diameter_min')::DECIMAL as diametro_km_min,
        (estimated_diameter->'$.kilometers'->>'$.estimated_diameter_max')::DECIMAL as diametro_km_max,
        
        absolute_magnitude_h,
        _airbyte_extracted_at
    from source
)

select * from renamed
