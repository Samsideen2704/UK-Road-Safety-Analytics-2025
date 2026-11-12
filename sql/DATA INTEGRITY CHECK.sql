## COLLISIONS TABLE

-- check collision table for zero or wrong values
SELECT
    collision_index,
    location_easting_osgr,
    location_northing_osgr,
    longitude,
    latitude
FROM collisions
WHERE longitude = 0
   OR latitude = 0
   OR location_easting_osgr = 0
   OR location_northing_osgr = 0
LIMIT 20;


SELECT
    COUNT(*) AS total_collisions,
    SUM(
        location_easting_osgr = 0
        AND location_northing_osgr = 0
        AND longitude = 0
        AND latitude = 0
    ) AS all_coordinates_zero,
    SUM(
        longitude NOT BETWEEN -8 AND 2
        OR latitude NOT BETWEEN 49 AND 61
    ) AS coordinates_outside_uk_range
FROM collisions;


-- view the values that has no location details
SELECT
    collision_index,
    location_easting_osgr,
    location_northing_osgr,
    longitude,
    latitude
FROM collisions
WHERE collision_index IN (
    '2025622500721',
    '2025622500752'
);



-- set zero values and convert to null
SELECT
    COUNT(*) AS total_collisions,
    COUNT(DISTINCT collision_index) AS unique_collisions,
    SUM(latitude IS NULL OR longitude IS NULL) AS missing_coordinates
FROM collisions;



## VEHICLES TABLE

-- change the collision index field name

ALTER TABLE vehicles
CHANGE COLUMN `ï»¿collision_index`
`collision_index` TEXT NULL;


-- check for errors (length of values) in collision index field

SELECT
    LENGTH(collision_index) AS id_length,
    COUNT(*) AS row_count,
    COUNT(DISTINCT collision_index) AS distinct_ids
FROM vehicles
GROUP BY LENGTH(collision_index)
ORDER BY id_length;


-- count collision index against vehicle records for distinct values
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT collision_index, vehicle_reference) AS unique_vehicle_records
FROM vehicles;


-- view wrong age inputs (0 and -1) from the vehicle table
SELECT
    COUNT(*) AS total_rows,

    SUM(age_of_driver = -1) AS original_driver_age_missing,
    SUM(age_of_driver_clean IS NULL) AS clean_driver_age_nulls,
    SUM(age_of_driver_clean = 0) AS clean_driver_age_zeros,
    SUM(age_of_driver_clean = -1) AS clean_driver_age_minus_ones,

    SUM(age_band_of_driver = -1) AS original_age_band_missing,
    SUM(age_band_of_driver_clean IS NULL) AS clean_age_band_nulls,
    SUM(age_band_of_driver_clean = 0) AS clean_age_band_zeros,
    SUM(age_band_of_driver_clean = -1) AS clean_age_band_minus_ones
FROM vehicles;


SELECT
    age_of_driver,
    age_of_driver_clean,
    age_band_of_driver,
    age_band_of_driver_clean
FROM vehicles
WHERE age_of_driver = -1
LIMIT 10;


-- set wrong age inputs to null for easy reading and analysis
UPDATE vehicles
SET
    age_of_driver_clean =
        CASE
            WHEN age_of_driver = -1 THEN NULL
            ELSE age_of_driver
        END,
    age_band_of_driver_clean =
        CASE
            WHEN age_band_of_driver = -1 THEN NULL
            ELSE age_band_of_driver
        END;
        
	
 -- verify the edits of the wrong age input   
SELECT
    COUNT(*) AS total_rows,
    SUM(age_of_driver = -1) AS original_age_missing,
    SUM(age_of_driver_clean IS NULL) AS clean_age_nulls,
    SUM(age_of_driver_clean = 0) AS clean_age_zeros,
    SUM(age_band_of_driver = -1) AS original_age_band_missing,
    SUM(age_band_of_driver_clean IS NULL) AS clean_age_band_nulls,
    SUM(age_band_of_driver_clean = 0) AS clean_age_band_zeros
FROM vehicles;



-- SET WRONG INPUTS (-1 AND 0) IN OUR TABLE TO NULL 

SELECT
    COUNT(*) AS total_rows,

    SUM(age_of_vehicle = -1) AS vehicle_age_unavailable,

    SUM(lsoa_of_driver = '-1') AS original_lsoa_missing,
    SUM(lsoa_of_driver_clean IS NULL) AS clean_lsoa_nulls,

    SUM(collision_index IS NULL) AS missing_collision_ids,
    SUM(vehicle_reference IS NULL) AS missing_vehicle_references
FROM vehicles;


UPDATE vehicles
SET lsoa_of_driver_clean = NULL
WHERE lsoa_of_driver = '-1';


SELECT
    COUNT(*) AS total_rows,
    SUM(lsoa_of_driver = '-1') AS original_lsoa_missing,
    SUM(lsoa_of_driver_clean IS NULL) AS clean_lsoa_nulls
FROM vehicles;


-- VIEW AND EDIT VEHICLE TYPES
SELECT
    vehicle_type_label,
    COUNT(*) AS records
FROM vehicles
GROUP BY vehicle_type_label
ORDER BY records DESC;



SELECT
    vehicle_type,
    COUNT(*) AS records
FROM vehicles
WHERE vehicle_type_label = 'Review code'
GROUP BY vehicle_type
ORDER BY vehicle_type;


UPDATE vehicles
SET vehicle_type_label = 'Data missing or out of range'
WHERE vehicle_type = -1;


-- VERIFY THE EDITS
SELECT
    vehicle_type_label,
    COUNT(*) AS records
FROM vehicles
GROUP BY vehicle_type_label
ORDER BY records DESC;


-- VIEW AND EDIT WRONG OR MISSING INPUTS IN ALL FIELDS OF VEHICLE TABLE
SELECT 'vehicle_manoeuvre_label' AS label_column,
       SUM(vehicle_manoeuvre_label IS NULL) AS nulls,
       SUM(TRIM(vehicle_manoeuvre_label) = '') AS blanks,
       SUM(vehicle_manoeuvre_label = 'Review code') AS review_codes
FROM vehicles

UNION ALL

SELECT 'vehicle_location_restricted_lane_label',
       SUM(vehicle_location_restricted_lane_label IS NULL),
       SUM(TRIM(vehicle_location_restricted_lane_label) = ''),
       SUM(vehicle_location_restricted_lane_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'hit_object_in_carriageway_label',
       SUM(hit_object_in_carriageway_label IS NULL),
       SUM(TRIM(hit_object_in_carriageway_label) = ''),
       SUM(hit_object_in_carriageway_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'hit_object_off_carriageway_label',
       SUM(hit_object_off_carriageway_label IS NULL),
       SUM(TRIM(hit_object_off_carriageway_label) = ''),
       SUM(hit_object_off_carriageway_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'first_point_of_impact_label',
       SUM(first_point_of_impact_label IS NULL),
       SUM(TRIM(first_point_of_impact_label) = ''),
       SUM(first_point_of_impact_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'vehicle_direction_from_label',
       SUM(vehicle_direction_from_label IS NULL),
       SUM(TRIM(vehicle_direction_from_label) = ''),
       SUM(vehicle_direction_from_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'vehicle_direction_to_label',
       SUM(vehicle_direction_to_label IS NULL),
       SUM(TRIM(vehicle_direction_to_label) = ''),
       SUM(vehicle_direction_to_label = 'Review code')
FROM vehicles

UNION ALL

SELECT 'vehicle_leaving_carriageway_label',
       SUM(vehicle_leaving_carriageway_label IS NULL),
       SUM(TRIM(vehicle_leaving_carriageway_label) = ''),
       SUM(vehicle_leaving_carriageway_label = 'Review code')
FROM vehicles;


SELECT
    vehicle_manoeuvre,
    COUNT(*) AS records
FROM vehicles
WHERE vehicle_manoeuvre_label = 'Review code'
GROUP BY vehicle_manoeuvre
ORDER BY vehicle_manoeuvre;


UPDATE vehicles
SET vehicle_manoeuvre_label = 'Data missing or out of range'
WHERE vehicle_manoeuvre = -1;


SELECT
    vehicle_manoeuvre_label,
    COUNT(*) AS records
FROM vehicles
GROUP BY vehicle_manoeuvre_label
ORDER BY records DESC;



SELECT
    vehicle_location_restricted_lane,
    COUNT(*) AS records
FROM vehicles
WHERE vehicle_location_restricted_lane_label = 'Review code'
GROUP BY vehicle_location_restricted_lane
ORDER BY vehicle_location_restricted_lane;


UPDATE vehicles
SET vehicle_location_restricted_lane_label = 'Data missing or out of range'
WHERE vehicle_location_restricted_lane = -1;


SELECT
    hit_object_in_carriageway,
    COUNT(*) AS records
FROM vehicles
WHERE hit_object_in_carriageway_label = 'Review code'
GROUP BY hit_object_in_carriageway
ORDER BY hit_object_in_carriageway;


UPDATE vehicles
SET hit_object_in_carriageway_label =
    CASE hit_object_in_carriageway
        WHEN 10 THEN 'Kerb'
        WHEN 11 THEN 'Other object in carriageway'
        WHEN 12 THEN 'Animal in carriageway'
        WHEN 99 THEN 'Unknown - self-reported'
    END
WHERE hit_object_in_carriageway IN (10, 11, 12, 99);        
       
       
       
       SELECT
    hit_object_off_carriageway,
    COUNT(*) AS records
FROM vehicles
WHERE hit_object_off_carriageway_label = 'Review code'
GROUP BY hit_object_off_carriageway
ORDER BY hit_object_off_carriageway;




UPDATE vehicles
SET hit_object_off_carriageway_label = 'Data missing or out of range'
WHERE hit_object_off_carriageway = -1;



SELECT
    first_point_of_impact,
    COUNT(*) AS records
FROM vehicles
WHERE first_point_of_impact_label = 'Review code'
GROUP BY first_point_of_impact
ORDER BY first_point_of_impact;



UPDATE vehicles
SET first_point_of_impact_label = 'Data missing or out of range'
WHERE first_point_of_impact = -1;



SELECT
    vehicle_direction_from,
    COUNT(*) AS records
FROM vehicles
WHERE vehicle_direction_from_label = 'Review code'
GROUP BY vehicle_direction_from
ORDER BY vehicle_direction_from;


UPDATE vehicles
SET vehicle_direction_from_label = 'Data missing or out of range'
WHERE vehicle_direction_from = -1;


-- EDIT WRONG (0 AND -1)VALUES IN ALL FIEDS OF VEHICLE TABLE

UPDATE vehicles
SET
    vehicle_type_label =
        CASE WHEN vehicle_type = -1
             AND vehicle_type_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_type_label END,

    vehicle_manoeuvre_label =
        CASE WHEN vehicle_manoeuvre = -1
             AND vehicle_manoeuvre_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_manoeuvre_label END,

    vehicle_location_restricted_lane_label =
        CASE WHEN vehicle_location_restricted_lane = -1
             AND vehicle_location_restricted_lane_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_location_restricted_lane_label END,

    hit_object_in_carriageway_label =
        CASE WHEN hit_object_in_carriageway = -1
             AND hit_object_in_carriageway_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE hit_object_in_carriageway_label END,

    hit_object_off_carriageway_label =
        CASE WHEN hit_object_off_carriageway = -1
             AND hit_object_off_carriageway_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE hit_object_off_carriageway_label END,

    first_point_of_impact_label =
        CASE WHEN first_point_of_impact = -1
             AND first_point_of_impact_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE first_point_of_impact_label END,

    vehicle_direction_from_label =
        CASE WHEN vehicle_direction_from = -1
             AND vehicle_direction_from_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_direction_from_label END,

    vehicle_direction_to_label =
        CASE WHEN vehicle_direction_to = -1
             AND vehicle_direction_to_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_direction_to_label END,

    vehicle_leaving_carriageway_label =
        CASE WHEN vehicle_leaving_carriageway = -1
             AND vehicle_leaving_carriageway_label = 'Review code'
             THEN 'Data missing or out of range'
             ELSE vehicle_leaving_carriageway_label 
	END;
             
             
             
	SELECT 'vehicle_type_label' AS label_column,
       SUM(vehicle_type_label = 'Review code') AS review_codes
FROM vehicles

UNION ALL
SELECT 'vehicle_manoeuvre_label',
       SUM(vehicle_manoeuvre_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'vehicle_location_restricted_lane_label',
       SUM(vehicle_location_restricted_lane_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'hit_object_in_carriageway_label',
       SUM(hit_object_in_carriageway_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'hit_object_off_carriageway_label',
       SUM(hit_object_off_carriageway_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'first_point_of_impact_label',
       SUM(first_point_of_impact_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'vehicle_direction_from_label',
       SUM(vehicle_direction_from_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'vehicle_direction_to_label',
       SUM(vehicle_direction_to_label = 'Review code')
FROM vehicles

UNION ALL
SELECT 'vehicle_leaving_carriageway_label',
       SUM(vehicle_leaving_carriageway_label = 'Review code')
FROM vehicles;



SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT collision_index, vehicle_reference) AS unique_vehicle_records,
    COUNT(DISTINCT collision_index) AS distinct_collisions,
    SUM(collision_index IS NULL) AS missing_collision_ids,
    SUM(vehicle_reference IS NULL) AS missing_vehicle_references
FROM vehicles;


-- -- validate collisions to vehicle matching records
SELECT
    COUNT(*) AS total_vehicle_records,
    SUM(c.collision_index IS NOT NULL) AS matched_records,
    SUM(c.collision_index IS NULL) AS unmatched_records
FROM vehicles v
LEFT JOIN collisions c
    ON v.collision_index = c.collision_index;
    


-- confirm the number of vehicle records against the number_of_vehicles in collisions.    
SELECT
    c.collision_index,
    c.number_of_vehicles AS reported_vehicles,
    COUNT(v.vehicle_reference) AS actual_vehicles
FROM collisions c
LEFT JOIN vehicles v
    ON c.collision_index = v.collision_index
GROUP BY
    c.collision_index,
    c.number_of_vehicles
HAVING
    c.number_of_vehicles <> COUNT(v.vehicle_reference);




    
    
## CASUALTIES TABLE

-- change field name
ALTER TABLE casualties
CHANGE COLUMN `ï»¿collision_index`
`collision_index` TEXT NULL;


-- Correct the cleaned age column
UPDATE casualties
SET age_of_casualty_clean = NULL
WHERE age_of_casualty = -1;


-- Verify the correction

SELECT
    COUNT(*) AS total_rows,
    SUM(age_of_casualty = -1) AS original_missing_ages,
    SUM(age_of_casualty_clean IS NULL) AS cleaned_null_ages,
    SUM(age_of_casualty_clean = 0) AS cleaned_zero_ages
FROM casualties;


-- validate unique casualty records

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT collision_index, casualty_reference)
        AS unique_casualty_records,
    COUNT(DISTINCT collision_index)
        AS distinct_collisions,
    SUM(collision_index IS NULL)
        AS missing_collision_ids,
    SUM(casualty_reference IS NULL)
        AS missing_casualty_references
FROM casualties;


-- Validate casualty-to-collision matching records

SELECT
    COUNT(*) AS total_casualty_records,
    SUM(c.collision_index IS NOT NULL) AS matched_records,
    SUM(c.collision_index IS NULL) AS unmatched_records
FROM casualties ca
LEFT JOIN collisions c
    ON ca.collision_index = c.collision_index;
    
-- check the number of casualty records against the number_of_casualties recorded in the collisions table.
SELECT
    c.collision_index,
    c.number_of_casualties AS reported_casualties,
    COUNT(ca.casualty_reference) AS actual_casualties
FROM collisions c
LEFT JOIN casualties ca
    ON c.collision_index = ca.collision_index
GROUP BY
    c.collision_index,
    c.number_of_casualties
HAVING
    c.number_of_casualties <> COUNT(ca.casualty_reference);
    
    
DESCRIBE collisions;

-- convert the collision date field to date function

UPDATE collisions
SET `date` = STR_TO_DATE(TRIM(`date`), '%d/%m/%Y');

ALTER TABLE collisions
MODIFY COLUMN `date` DATE;

-- convert time colum to time function
ALTER TABLE collisions
MODIFY COLUMN `time` TIME NULL;


-- Verify the date and time columns
    
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'collisions'
  AND COLUMN_NAME IN ('date', 'time', 'collision_date_clean', 'collision_time_clean')
ORDER BY COLUMN_NAME;
    
    
SELECT
    COUNT(*) AS total_collisions,
    SUM(`date` IS NULL) AS missing_dates,
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date,
    SUM(`time` IS NULL) AS missing_times
FROM collisions;



