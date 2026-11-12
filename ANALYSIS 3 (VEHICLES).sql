### VEHICLE CHARACTERISTICS AND COLLISION SEVERITY ANALYSIS

-- 21: Vehicle Type and Collision Severity

SELECT
    v.vehicle_type_label AS vehicle_type,
    c.collision_severity_label AS collision_severity,
    COUNT(*) AS vehicle_count,
    COUNT(DISTINCT v.collision_index) AS collision_count
FROM vehicles AS v
INNER JOIN collisions AS c
    ON v.collision_index = c.collision_index
GROUP BY
    v.vehicle_type_label,
    c.collision_severity_label
ORDER BY
    vehicle_type,
    CASE c.collision_severity_label
        WHEN 'Fatal' THEN 1
        WHEN 'Serious' THEN 2
        WHEN 'Slight' THEN 3
        ELSE 4
    END;
    
    
-- 22: Vehicle Type by Collision Severity
-- Compare vehicle counts across collision severity categories.

SELECT
    v.vehicle_type_label AS vehicle_type,

    SUM(CASE
        WHEN c.collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_vehicle_count,

    SUM(CASE
        WHEN c.collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_vehicle_count,

    SUM(CASE
        WHEN c.collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_vehicle_count,

    COUNT(*) AS total_vehicle_records

FROM vehicles AS v
INNER JOIN collisions AS c
    ON v.collision_index = c.collision_index

GROUP BY v.vehicle_type_label
ORDER BY total_vehicle_records DESC;



-- 23: Vehicle Manoeuvre and Collision Severity

SELECT
    v.vehicle_manoeuvre_label AS vehicle_manoeuvre,

    SUM(CASE
        WHEN c.collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_vehicle_records,

    ROUND(
        SUM(CASE
            WHEN c.collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN c.collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_vehicle_records,

    COUNT(*) AS total_vehicle_records

FROM vehicles AS v
INNER JOIN collisions AS c
    ON v.collision_index = c.collision_index

GROUP BY v.vehicle_manoeuvre_label
ORDER BY total_vehicle_records DESC;



-- 24: Vehicle Type and Manoeuvre in Fatal Collisions

SELECT
    v.vehicle_type_label AS vehicle_type,
    v.vehicle_manoeuvre_label AS vehicle_manoeuvre,

    COUNT(*) AS fatal_vehicle_records,

    COUNT(DISTINCT v.collision_index) AS fatal_collision_count

FROM vehicles AS v
INNER JOIN collisions AS c
    ON v.collision_index = c.collision_index

WHERE c.collision_severity_label = 'Fatal'

GROUP BY
    v.vehicle_type_label,
    v.vehicle_manoeuvre_label

ORDER BY
    fatal_vehicle_records DESC,
    fatal_collision_count DESC;
    
    
    
-- 25: Vehicle Type, Urban/Rural Area and Severity

SELECT
    c.urban_or_rural_area_label AS area_type,
    v.vehicle_type_label AS vehicle_type,

    SUM(CASE
        WHEN c.collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_vehicle_records,

    SUM(CASE
        WHEN c.collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_vehicle_records,

    COUNT(*) AS total_vehicle_records,

    COUNT(DISTINCT CASE
        WHEN c.collision_severity_label = 'Fatal'
        THEN c.collision_index
    END) AS fatal_collision_count

FROM vehicles AS v
INNER JOIN collisions AS c
    ON v.collision_index = c.collision_index

GROUP BY
    c.urban_or_rural_area_label,
    v.vehicle_type_label

ORDER BY
    area_type,
    total_vehicle_records DESC;
    
    
    
-- 26: Fatal Collisions by Speed Limit

SELECT
    speed_limit_label AS speed_limit,

    COUNT(*) AS fatal_collision_count,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM collisions
         WHERE collision_severity_label = 'Fatal'),
        2
    ) AS percentage_of_fatal_collisions

FROM collisions
WHERE collision_severity_label = 'Fatal'

GROUP BY speed_limit_label

ORDER BY fatal_collision_count DESC;




-- 27: Collision Severity by Speed Limit

SELECT
    speed_limit_label AS speed_limit,

    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_collisions

FROM collisions

GROUP BY speed_limit_label

ORDER BY total_collisions DESC;


 
-- 28: Collision Severity by First Road Class

SELECT
    first_road_class_label AS road_class,

    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_collisions

FROM collisions

GROUP BY first_road_class_label

ORDER BY total_collisions DESC;



-- 29: Collision Severity by Junction Control

SELECT
    junction_control_label AS junction_control,

    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_collisions

FROM collisions

GROUP BY junction_control_label

ORDER BY total_collisions DESC;




-- 30: Junction Control Data-Quality Audit

SELECT
    junction_control,
    junction_control_label,
    COUNT(*) AS collision_count,
    SUM(
        CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END
    ) AS fatal_collisions

FROM collisions

GROUP BY
    junction_control,
    junction_control_label

ORDER BY collision_count DESC;




-- 31: Collision Severity by Light and Weather Conditions

SELECT
    light_conditions_label AS light_condition,
    weather_conditions_label AS weather_condition,

    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_collisions

FROM collisions

GROUP BY
    light_conditions_label,
    weather_conditions_label

ORDER BY
    fatal_pct DESC,
    total_collisions DESC;
    
    
    
-- 32: Collision Severity by Month and Urban/Rural Area

SELECT
    MONTH(`date`) AS month_number,
    MONTHNAME(`date`) AS month_name,
    urban_or_rural_area_label AS area_type,

    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_collisions

FROM collisions

GROUP BY
    MONTH(`date`),
    MONTHNAME(`date`),
    urban_or_rural_area_label

ORDER BY
    month_number,
    area_type;
    
    
    
  
-- 33: Fatal Collisions by Month

SELECT
    MONTH(`date`) AS month_number,
    MONTHNAME(`date`) AS month_name,

    COUNT(*) AS total_collisions,

    SUM(
        CASE
            WHEN collision_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END
    ) AS fatal_collisions,

    ROUND(
        SUM(
            CASE
                WHEN collision_severity_label = 'Fatal'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(
        CASE
            WHEN collision_severity_label = 'Serious'
            THEN 1 ELSE 0
        END
    ) AS serious_collisions,

    SUM(
        CASE
            WHEN collision_severity_label = 'Slight'
            THEN 1 ELSE 0
        END
    ) AS slight_collisions

FROM collisions

GROUP BY
    MONTH(`date`),
    MONTHNAME(`date`)

ORDER BY
    month_number;
    
    
    
    -- 34: Collision Severity by Day of Week

SELECT
    day_of_week,
    CASE day_of_week
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
        ELSE 'Unknown'
    END AS day_name,
    COUNT(*) AS total_collisions,
    SUM(collision_severity_label = 'Fatal') AS fatal_collisions,
    ROUND(
        SUM(collision_severity_label = 'Fatal') * 100.0
        / COUNT(*), 2
    ) AS fatal_pct,
    SUM(collision_severity_label = 'Serious') AS serious_collisions,
    SUM(collision_severity_label = 'Slight') AS slight_collisions
FROM collisions
GROUP BY day_of_week, day_name
ORDER BY day_of_week;





-- 35: Light Condition and Road Surface
-- Compare collision severity across lighting and road surface combinations.

SELECT
    light_conditions_label AS light_condition,
    road_surface_conditions_label AS road_surface,
    COUNT(*) AS total_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Fatal' THEN 1
        ELSE 0
    END) AS fatal_collisions,

    ROUND(
        SUM(CASE
            WHEN collision_severity_label = 'Fatal' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN collision_severity_label = 'Serious' THEN 1
        ELSE 0
    END) AS serious_collisions,

    SUM(CASE
        WHEN collision_severity_label = 'Slight' THEN 1
        ELSE 0
    END) AS slight_collisions

FROM collisions
GROUP BY
    light_conditions_label,
    road_surface_conditions_label
ORDER BY
    fatal_pct DESC,
    total_collisions DESC;

    