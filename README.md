# UK Road Safety Analytics — 2025
#### Analysis of 2025 UK road safety data using Excel, MySQL and Tableau.

## Project Overview

This project explores patterns in road traffic collisions across England and Wales using the 2025 UK Road Safety dataset published by the Department for Transport (DfT).

I worked with three interconnected datasets covering collisions, vehicles and casualties. Using Excel Power Query, MySQL and Tableau, I cleaned and prepared the data, carried out SQL analysis and developed visual dashboards to explore collision severity and the factors associated with different outcomes.

The aim was to turn raw road safety data into meaningful insights and identify patterns across road conditions, locations, vehicles and road users.

## Business Problem

Road traffic collisions occur under different circumstances, and understanding the patterns behind them can help highlight areas that may need further attention.

I used this project to investigate how collision severity varies across road types, junctions, weather conditions, casualty characteristics, vehicle types and driver-related factors.

## Project Objectives

- Which road types and junctions had the highest number of collisions?

- How did weather and lighting conditions relate to collision severity?

- Which groups of road users were more likely to be involved in serious or fatal outcomes?

- What types of vehicles were most commonly involved in collisions?

- Did collision severity vary across different vehicle manoeuvres?

- Which local authority areas recorded the highest number of collisions?


## Dataset

**Source:** UK Department for Transport — Road Safety Data, 2025.

The project uses three CSV datasets:

| Dataset | Records |
|---|---:|
| Collisions | 101,525 |
| Vehicles | 183,948 |
| Casualties | 127,883 |

The datasets are connected by the _`collision_index`_ field.

## Tools and Technologies I used

- Excel Power Query: To clean the data, handle missing values and prepare the datasets.

- MySQL Workbench: To create the database, write SQL queries, combine tables and check data quality.

- Tableau: To build charts and dashboards and present the findings.


## Project Workflow

### 1. Data Cleaning and Preparation

I started by exploring the three datasets to understand their structure and identify anything that needed attention.

Some of the issues I came across included:

- Negative age values, such as -1, representing unavailable information.

- Missing and incomplete location information.

- Inconsistent category values and spelling errors.

- Issues with some latitude and longitude values during data import.

I used Power Query to clean and transform the data, standardise categories and prepare additional fields for analysis.

### 2. SQL Analysis

Once the data was prepared, I imported the three datasets into MySQL Workbench.

I created separate tables for collisions, vehicles and casualties and connected them using collision_index.

I then used SQL to:

- Investigate missing values and check for duplicate records.

- Combine information from the three tables using JOINs.

- Calculate collision, vehicle and casualty counts.

- Compare collision severity across different categories.

- Group and summarise records.

- Rank results using window functions.


### 3. Data Validation

I didn't want to assume that the data was correct simply because it had been imported successfully.
I carried out the follwing checks to make sure the tables were properly connected and the records were consistent:

- I checked for duplicate identifiers.
- I verified relationships between the three tables.
- I confirmed that vehicle and casualty records matched existing collision records.
- I checked recorded vehicle and casualty counts against their respective tables.
- I investigated missing and unavailable values.


### 4. Tableau Visualisation

After completing the SQL analysis, I moved to Tableau to explore the findings visually.

I organised the visualisations into three main areas:

**Collision Overview**

- Collision severity by road type.

- Collision severity by junction type.

- Collision severity by weather conditions.

- Collision counts and severity rates across weather and road types.

- Top 10 local authorities by collision count.

**Casualty Analysis**

- Casualty severity by road-user type.

- Casualty severity by gender.

- Casualty severity across different age groups.

**Vehicle and Driver Analysis**

- Collisions by vehicle type.

- Vehicle type by collision severity.

- Collision severity by vehicle manoeuvre.

- Vehicle manoeuvre severity distribution.

- First point of impact by severity.

- Collision severity by driver gender.



## Key Findings

Some of the key patterns I identified with my analysis include:

- Out of 101,525 recorded collisions, 74,881 were slight, 25,191 were serious and 1,453 were fatal.

- Single carriageways had a higher proportion of serious collisions (26.42%) than dual carriageways (22.72%).

- Pedestrians had a higher proportion of serious casualties (29.19%) compared with drivers or riders (21.17%) and passengers (17.33%).

- Casualties aged 75 and above had the highest fatal severity proportion across the age groups, at 3.98%.

- Motorcycles over 500cc had a serious severity proportion of 48.07% in the vehicle analysis.

- Male drivers had a higher proportion of serious collision records (25.78%) than female drivers (22.32%).

- Birmingham recorded the highest number of collisions among the ten local authorities analysed, with 2,307.

These findings helped me see how collision severity varied across different road conditions, vehicle categories and groups of road users.

## Project Limitations

There were some limitations to the data that I had to consider during the analysis.

- The dataset covers police-reported personal-injury collisions, so it may not include every road traffic incident.

- Some fields contained missing or unavailable information.

- Vehicle age was unavailable across all vehicle records, so I excluded it from the analysis.

- Some location data had completeness and import issues.

- Collision counts alone do not tell us how risky a road or area is, because traffic volume and road usage were not included.

The findings show patterns and associations in the available data. They do not prove that a particular factor caused a collision.


## Repository Structure

```text
UK-Road-Safety-Analytics-2025/
│
├── sql/
│   └── SQL analysis and validation scripts
│
├── tableau/
│   └── Tableau workbook
│
├── screenshots/
│   └── Dashboard screenshots
│
├── data/
│   └── Dataset source information
│
└── README.md
```

## Conclusion

This project gave me the opportunity to work with a larger dataset involving multiple related tables.

I gained more experience using Power Query to prepare data, SQL to investigate and validate records, and Tableau to present findings through dashboards.

One of the biggest lessons was that data analysis involves more than writing queries and creating charts. Understanding the data, checking its quality and knowing its limitations are just as important as the final results.

#### Key skills I demonstrated

Data cleaning, Excel Power Query, SQL, MySQL, relational databases, data validation, exploratory data analysis, Tableau and data visualisation.
