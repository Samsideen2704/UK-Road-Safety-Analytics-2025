
## ROAD CHARACTERISTICS AND COLLISION SEVERITY ANALYSIS 

-- 01: Collision Severity Baseline
-- What is the distribution of fatal, serious and slight collisions ?
-- Purpose: Measure collision counts and percentage by severity.

SELECT
    collision_severity_label AS severity,
    COUNT(*) AS collision_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM collisions),
        2
    ) AS percentage_of_collisions
FROM collisions
GROUP BY collision_severity_label
ORDER BY
    CASE collision_severity_label
        WHEN 'Fatal' THEN 1
        WHEN 'Serious' THEN 2
        WHEN 'Slight' THEN 3
        ELSE 4
    END;


-- Confirm the total number of collisions and severity distribution.

SELECT
    COUNT(*) AS total_collisions,
    SUM(collision_severity_label = 'Fatal') AS fatal_collisions,
    SUM(collision_severity_label = 'Serious') AS serious_collisions,
    SUM(collision_severity_label = 'Slight') AS slight_collisions,
    SUM(collision_severity_label NOT IN ('Fatal', 'Serious', 'Slight'))
        AS other_or_unexpected_severity
FROM collisions;



-- 03: Monthly Collision Trends
-- Measure recorded collisions in each month.

SELECT
    MONTH(`date`) AS month_number,
    MONTHNAME(`date`) AS month_name,
    COUNT(*) AS collision_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM collisions),
        2
    ) AS percentage_of_collisions
FROM collisions
GROUP BY
    MONTH(`date`),
    MONTHNAME(`date`)
ORDER BY month_number;




-- 04: Collision Patterns by Day of Week
-- Compare collision counts across weekdays.

SELECT
    day_of_week,
    CASE 
		WHEN day_of_week = 1 THEN 'Monday'
		WHEN day_of_week = 2 THEN 'Tuesday'
		WHEN day_of_week = 3 THEN 'Wednesday'
		WHEN day_of_week = 4 THEN 'Thursday'
		WHEN day_of_week = 5 THEN 'Friday'
		WHEN day_of_week = 6 THEN 'Saturday'
		WHEN day_of_week = 7 THEN 'Sunday'
    END AS day_name,
    
    COUNT(*) AS collision_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM collisions),
        2
    ) AS percentage_of_collisions
FROM collisions
GROUP BY day_of_week, day_name
ORDER BY day_of_week;



-- 05: Collision Severity by Day of Week
-- Compare severity distribution within each day.

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
    collision_severity_label AS severity,
    COUNT(*) AS collision_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY day_of_week),
        2
    ) AS percentage_within_day
FROM collisions
GROUP BY
    day_of_week,
    collision_severity_label
ORDER BY
    day_of_week,
    CASE collision_severity_label
        WHEN 'Fatal' THEN 1
        WHEN 'Serious' THEN 2
        WHEN 'Slight' THEN 3
        ELSE 4
    END;
    
    
-- 06: Collision Patterns by Hour of Day
-- Identify hours with the highest collision counts.

SELECT
    HOUR(`time`) AS collision_hour,
    COUNT(*) AS collision_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM collisions),
        2
    ) AS percentage_of_collisions
FROM collisions
GROUP BY HOUR(`time`)
ORDER BY collision_hour;



--  07: Collision Severity by Hour
-- Compare severity counts and percentages within each hour.

WITH hourly_severity AS (
    SELECT
        HOUR(`time`) AS collision_hour,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (PARTITION BY HOUR(`time`)),
            2
        ) AS percentage_within_hour
    FROM collisions
    GROUP BY
        HOUR(`time`),
        collision_severity_label
)
SELECT
    collision_hour,

    MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END) AS fatal_count,
    MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_hour END) AS fatal_pct,

    MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END) AS serious_count,
    MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_hour END) AS serious_pct,

    MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END) AS slight_count,
    MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_hour END) AS slight_pct

FROM hourly_severity
GROUP BY collision_hour
ORDER BY collision_hour;





-- 08: Light Conditions and Collision Severity
-- Compare collision severity across lighting conditions.

WITH light_severity AS (
    SELECT
        light_conditions_label AS light_condition,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY light_conditions_label
            ),
            2
        ) AS percentage_within_condition
    FROM collisions
    GROUP BY
        light_conditions_label,
        collision_severity_label
)
SELECT
    light_condition,

    MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END) AS fatal_count,
    MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_condition END) AS fatal_pct,

    MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END) AS serious_count,
    MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_condition END) AS serious_pct,

    MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END) AS slight_count,
    MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_condition END) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM light_severity
GROUP BY light_condition
ORDER BY total_collisions DESC;  



-- Query 09: Road Surface Conditions and Collision Severity

WITH surface_severity AS (
    SELECT
        road_surface_conditions_label AS road_surface,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY road_surface_conditions_label
            ),
            2
        ) AS percentage_within_surface
    FROM collisions
    GROUP BY
        road_surface_conditions_label,
        collision_severity_label
)
SELECT
    road_surface,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_surface END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_surface END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_surface END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM surface_severity
GROUP BY road_surface
ORDER BY total_collisions DESC;




-- Query 10: Weather Conditions and Collision Severity

WITH weather_severity AS (
    SELECT
        weather_conditions_label AS weather_condition,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY weather_conditions_label
            ),
            2
        ) AS percentage_within_weather
    FROM collisions
    GROUP BY
        weather_conditions_label,
        collision_severity_label
)
SELECT
    weather_condition,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_weather END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_weather END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_weather END), 0) AS slight_pct,

	SUM(collision_count) AS total_collisions

FROM weather_severity
GROUP BY weather_condition
ORDER BY total_collisions DESC;



-- 11: Speed Limit and Collision Severity

WITH speed_severity AS (
    SELECT
        speed_limit_label AS speed_limit,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY speed_limit_label
            ),
            2
        ) AS percentage_within_speed_limit
    FROM collisions
    GROUP BY
        speed_limit_label,
        collision_severity_label
)
SELECT
    speed_limit,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_speed_limit END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_speed_limit END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_speed_limit END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM speed_severity
GROUP BY speed_limit
ORDER BY total_collisions DESC;




-- 12: Road Type and Collision Severity

WITH road_type_severity AS (
    SELECT
        road_type_label AS road_type,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY road_type_label
            ),
            2
        ) AS percentage_within_road_type
    FROM collisions
    GROUP BY
        road_type_label,
        collision_severity_label
)
SELECT
    road_type,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_road_type END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_road_type END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_road_type END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM road_type_severity
GROUP BY road_type
ORDER BY total_collisions DESC;





-- 13: Junction Detail and Collision Severity

WITH junction_severity AS (
    SELECT
        junction_detail_label AS junction_detail,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY junction_detail_label
            ),
            2
        ) AS percentage_within_junction
    FROM collisions
    GROUP BY
        junction_detail_label,
        collision_severity_label
)
SELECT
    junction_detail,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_junction END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_junction END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_junction END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM junction_severity
GROUP BY junction_detail
ORDER BY total_collisions DESC;




-- 14: Junction Control and Collision Severity

WITH junction_control_severity AS (
    SELECT
        junction_control_label AS junction_control,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY junction_control_label
            ),
            2
        ) AS percentage_within_control
    FROM collisions
    GROUP BY
        junction_control_label,
        collision_severity_label
)
SELECT
    junction_control,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_control END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_control END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_control END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM junction_control_severity
GROUP BY junction_control
ORDER BY total_collisions DESC;




-- 15: Urban vs Rural Collision Severity

WITH area_severity AS (
    SELECT
        urban_or_rural_area_label AS area_type,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY urban_or_rural_area_label
            ),
            2
        ) AS percentage_within_area
    FROM collisions
    GROUP BY
        urban_or_rural_area_label,
        collision_severity_label
)
SELECT
    area_type,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_area END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_area END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_area END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM area_severity
GROUP BY area_type
ORDER BY total_collisions DESC;



-- 16: First Road Class and Collision Severity

WITH road_class_severity AS (
    SELECT
        first_road_class_label AS road_class,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY first_road_class_label
            ),
            2
        ) AS percentage_within_class
    FROM collisions
    GROUP BY
        first_road_class_label,
        collision_severity_label
)
SELECT
    road_class,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_class END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_class END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_class END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM road_class_severity
GROUP BY road_class
ORDER BY total_collisions DESC;




--  17: Second Road Class and Collision Severity

WITH second_class_severity AS (
    SELECT
        second_road_class_label AS road_class,
        collision_severity_label AS severity,
        COUNT(*) AS collision_count,
        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (
                PARTITION BY second_road_class_label
            ),
            2
        ) AS percentage_within_class
    FROM collisions
    GROUP BY
        second_road_class_label,
        collision_severity_label
)
SELECT
    road_class,

    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN collision_count END), 0) AS fatal_count,
    COALESCE(MAX(CASE WHEN severity = 'Fatal'
        THEN percentage_within_class END), 0) AS fatal_pct,

    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN collision_count END), 0) AS serious_count,
    COALESCE(MAX(CASE WHEN severity = 'Serious'
        THEN percentage_within_class END), 0) AS serious_pct,

    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN collision_count END), 0) AS slight_count,
    COALESCE(MAX(CASE WHEN severity = 'Slight'
        THEN percentage_within_class END), 0) AS slight_pct,

    SUM(collision_count) AS total_collisions

FROM second_class_severity
GROUP BY road_class
ORDER BY total_collisions DESC;

