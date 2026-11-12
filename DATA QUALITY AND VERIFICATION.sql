## FINAL DATA QUALITY CHECK

-- 01: Collision severity reconciliation

SELECT
    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal' THEN 1
        ELSE 0
    END) AS fatal_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Serious' THEN 1
        ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight' THEN 1
        ELSE 0
    END) AS slight_collisions,

    SUM(CASE
        WHEN collision_severity_label IS NULL
          OR collision_severity_label NOT IN ('Fatal', 'Serious', 'Slight')
        THEN 1
        ELSE 0
    END) AS unexpected_severity_values

FROM collisions;



-- 02: Validate key collision fields

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT collision_index) AS unique_collision_ids,

    SUM(CASE
        WHEN collision_index IS NULL OR TRIM(collision_index) = ''
        THEN 1 ELSE 0
    END) AS missing_collision_ids,

    SUM(CASE
        WHEN `date` IS NULL
        THEN 1 ELSE 0
    END) AS missing_dates,

    SUM(CASE
        WHEN `time` IS NULL
        THEN 1 ELSE 0
    END) AS missing_times,

    SUM(CASE
        WHEN light_conditions_label IS NULL
          OR TRIM(light_conditions_label) = ''
        THEN 1 ELSE 0
    END) AS missing_light_labels,

    SUM(CASE
        WHEN weather_conditions_label IS NULL
          OR TRIM(weather_conditions_label) = ''
        THEN 1 ELSE 0
    END) AS missing_weather_labels,

    SUM(CASE
        WHEN road_surface_conditions_label IS NULL
          OR TRIM(road_surface_conditions_label) = ''
        THEN 1 ELSE 0
    END) AS missing_road_surface_labels

FROM collisions;



-- 03: Check vehicle and casualty table integrity

SELECT
    'Vehicles' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT(v.collision_index, '-', v.vehicle_reference))
        AS unique_records,
    COUNT(DISTINCT v.collision_index) AS distinct_collisions,
    SUM(CASE
        WHEN c.collision_index IS NULL THEN 1
        ELSE 0
    END) AS unmatched_records
FROM vehicles v
LEFT JOIN collisions c
    ON v.collision_index = c.collision_index

UNION ALL

SELECT
    'Casualties' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT(ca.collision_index, '-', ca.casualty_reference))
        AS unique_records,
    COUNT(DISTINCT ca.collision_index) AS distinct_collisions,
    SUM(CASE
        WHEN c.collision_index IS NULL THEN 1
        ELSE 0
    END) AS unmatched_records
FROM casualties ca
LEFT JOIN collisions c
    ON ca.collision_index = c.collision_index;
    
    
    

-- 04: Casualty severity label validation

SELECT
    COUNT(*) AS total_casualties,

    SUM(CASE
        WHEN casualty_severity_label = 'Fatal' THEN 1
        ELSE 0
    END) AS fatal_casualties,

    SUM(CASE
        WHEN casualty_severity_label = 'Serious' THEN 1
        ELSE 0
    END) AS serious_casualties,

    SUM(CASE
        WHEN casualty_severity_label = 'Slight' THEN 1
        ELSE 0
    END) AS slight_casualties,

    SUM(CASE
        WHEN casualty_severity_label IS NULL
          OR casualty_severity_label NOT IN ('Fatal', 'Serious', 'Slight')
        THEN 1
        ELSE 0
    END) AS unexpected_severity_labels

FROM casualties;


-- 05: Vehicle severity label validation

SELECT
    COUNT(*) AS total_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Fatal' THEN 1
        ELSE 0
    END) AS fatal_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Serious' THEN 1
        ELSE 0
    END) AS serious_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Slight' THEN 1
        ELSE 0
    END) AS slight_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label IS NULL
          OR c.collision_severity_label NOT IN ('Fatal', 'Serious', 'Slight')
        THEN 1
        ELSE 0
    END) AS unexpected_severity_labels

FROM vehicles v
LEFT JOIN collisions c
    ON v.collision_index = c.collision_index;
    
    
    
    
-- 06: Casualty age cleaning validation

SELECT
    COUNT(*) AS total_casualties,

    SUM(CASE
        WHEN age_of_casualty = -1 THEN 1
        ELSE 0
    END) AS original_missing_age_codes,

    SUM(CASE
        WHEN age_of_casualty_clean IS NULL THEN 1
        ELSE 0
    END) AS cleaned_null_ages,

    SUM(CASE
        WHEN age_of_casualty_clean = 0 THEN 1
        ELSE 0
    END) AS zero_age_records,

    SUM(CASE
        WHEN age_of_casualty_clean < 0 THEN 1
        ELSE 0
    END) AS remaining_negative_cleaned_ages

FROM casualties;




-- 07: Vehicle age availability

SELECT
    COUNT(*) AS total_vehicle_records,

    SUM(CASE
        WHEN age_of_vehicle = -1 THEN 1
        ELSE 0
    END) AS unavailable_age_codes,

    SUM(CASE
        WHEN age_of_vehicle IS NULL THEN 1
        ELSE 0
    END) AS null_vehicle_ages,

    SUM(CASE
        WHEN age_of_vehicle >= 0 THEN 1
        ELSE 0
    END) AS nonnegative_vehicle_ages

FROM vehicles;


-- 08: check the collision coordinates contain missing or invalid values,

SELECT
    COUNT(*) AS total_collisions,
    SUM(location_easting_osgr IS NULL) AS missing_easting,
    SUM(location_northing_osgr IS NULL) AS missing_northing,
    SUM(latitude IS NULL) AS missing_latitude,
    SUM(longitude IS NULL) AS missing_longitude
FROM collisions;


-- 09: Verify severity labels across all tables

SELECT
    'Collisions' AS source_table,
    collision_severity_label AS severity_label,
    COUNT(*) AS record_count
FROM collisions
GROUP BY collision_severity_label

UNION ALL

SELECT
    'Casualties' AS source_table,
    casualty_severity_label AS severity_label,
    COUNT(*) AS record_count
FROM casualties
GROUP BY casualty_severity_label

UNION ALL

SELECT
    'Vehicles (by collision severity)' AS source_table,
    c.collision_severity_label AS severity_label,
    COUNT(*) AS record_count
FROM vehicles v
INNER JOIN collisions c
    ON v.collision_index = c.collision_index
GROUP BY c.collision_severity_label

ORDER BY source_table, severity_label;


-- 09: Confirm collision-level percentages

SELECT
    COUNT(*) AS total_collisions,
    SUM(collision_severity_label = 'Fatal') AS fatal_collisions,
    SUM(collision_severity_label = 'Serious') AS serious_collisions,
    SUM(collision_severity_label = 'Slight') AS slight_collisions,
    ROUND(
        SUM(collision_severity_label = 'Fatal') * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,
    ROUND(
        SUM(collision_severity_label = 'Serious') * 100.0 / COUNT(*),
        2
    ) AS serious_pct,
    ROUND(
        SUM(collision_severity_label = 'Slight') * 100.0 / COUNT(*),
        2
    ) AS slight_pct
FROM collisions;




-- 10: Validate collision-level joins
-- Aggregate vehicles and casualties before joining.

SELECT
    COUNT(*) AS collision_rows,
    SUM(COALESCE(v.vehicle_count, 0)) AS total_vehicle_records,
    SUM(COALESCE(c.casualty_count, 0)) AS total_casualty_records,
    SUM(v.vehicle_count IS NULL) AS collisions_without_vehicle_records,
    SUM(c.casualty_count IS NULL) AS collisions_without_casualty_records
FROM collisions AS col
LEFT JOIN (
    SELECT
        collision_index,
        COUNT(*) AS vehicle_count
    FROM vehicles
    GROUP BY collision_index
) AS v
    ON col.collision_index = v.collision_index
LEFT JOIN (
    SELECT
        collision_index,
        COUNT(*) AS casualty_count
    FROM casualties
    GROUP BY collision_index
) AS c
    ON col.collision_index = c.collision_index;
    
    
    
-- 11: Check collision dates and times

SELECT
    COUNT(*) AS total_collisions,
    SUM(`date` IS NULL) AS missing_dates,
    SUM(`time` IS NULL OR TRIM(`time`) = '') AS missing_times,
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM collisions;


-- 12: Validate coordinates for mapping
SELECT
    COUNT(*) AS total_collisions,

    SUM(latitude IS NULL) AS missing_latitude,
    SUM(longitude IS NULL) AS missing_longitude,

    SUM(
        latitude IS NOT NULL
        AND (latitude < 49 OR latitude > 61)
    ) AS latitude_out_of_uk_range,

    SUM(
        longitude IS NOT NULL
        AND (longitude < -9 OR longitude > 3)
    ) AS longitude_out_of_uk_range

FROM collisions;