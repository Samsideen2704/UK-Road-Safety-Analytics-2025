## ROAD USER CHARACTERISTICS AND CASUALTY ANALYSIS


-- 18: Casualty Class and Casualty Severity
-- Purpose: Compare severity outcomes across casualty classes.

SELECT
    casualty_class_label AS casualty_class,

    SUM(CASE
        WHEN casualty_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN casualty_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Serious'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS serious_pct,

    SUM(CASE
        WHEN casualty_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Slight'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS slight_pct,

    COUNT(*) AS total_casualties

FROM casualties
GROUP BY casualty_class_label
ORDER BY total_casualties DESC;





--  19: Casualty Age Band and Severity
-- Compare casualty severity across age groups.

WITH age_severity AS (
    SELECT
        CASE
            WHEN age_of_casualty_clean BETWEEN 0 AND 15
                THEN '00-15'
            WHEN age_of_casualty_clean BETWEEN 16 AND 24
                THEN '16-24'
            WHEN age_of_casualty_clean BETWEEN 25 AND 34
                THEN '25-34'
            WHEN age_of_casualty_clean BETWEEN 35 AND 44
                THEN '35-44'
            WHEN age_of_casualty_clean BETWEEN 45 AND 54
                THEN '45-54'
            WHEN age_of_casualty_clean BETWEEN 55 AND 64
                THEN '55-64'
            WHEN age_of_casualty_clean BETWEEN 65 AND 74
                THEN '65-74'
            WHEN age_of_casualty_clean >= 75
                THEN '75+'
            ELSE 'Unknown'
        END AS age_band,

        casualty_severity_label AS severity,
        COUNT(*) AS casualty_count

    FROM casualties
    GROUP BY age_band, severity
)
SELECT
    age_band,

    COALESCE(SUM(CASE
        WHEN severity = 'Fatal' THEN casualty_count
        ELSE 0
    END), 0) AS fatal_casualties,

    COALESCE(SUM(CASE
        WHEN severity = 'Serious' THEN casualty_count
        ELSE 0
    END), 0) AS serious_casualties,

    COALESCE(SUM(CASE
        WHEN severity = 'Slight' THEN casualty_count
        ELSE 0
    END), 0) AS slight_casualties,

    SUM(casualty_count) AS total_casualties,

    ROUND(
        SUM(CASE
            WHEN severity = 'Fatal' THEN casualty_count
            ELSE 0
        END) * 100.0 / SUM(casualty_count),
        2
    ) AS fatal_pct

FROM age_severity
GROUP BY age_band
ORDER BY
    CASE age_band
        WHEN '00-15' THEN 1
        WHEN '16-24' THEN 2
        WHEN '25-34' THEN 3
        WHEN '35-44' THEN 4
        WHEN '45-54' THEN 5
        WHEN '55-64' THEN 6
        WHEN '65-74' THEN 7
        WHEN '75+' THEN 8
        ELSE 9
    END;
    
    
    
-- 20: Casualty Sex and Severity

SELECT
    sex_of_casualty_label AS casualty_sex,

    SUM(CASE
        WHEN casualty_severity_label = 'Fatal'
        THEN 1 ELSE 0
    END) AS fatal_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Fatal'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fatal_pct,

    SUM(CASE
        WHEN casualty_severity_label = 'Serious'
        THEN 1 ELSE 0
    END) AS serious_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Serious'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS serious_pct,

    SUM(CASE
        WHEN casualty_severity_label = 'Slight'
        THEN 1 ELSE 0
    END) AS slight_casualties,

    ROUND(
        SUM(CASE
            WHEN casualty_severity_label = 'Slight'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS slight_pct,

    COUNT(*) AS total_casualties

FROM casualties
GROUP BY sex_of_casualty_label
ORDER BY total_casualties DESC;
    
