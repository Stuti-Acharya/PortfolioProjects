# COVID-19 Data Exploration Using SQL

## Project Overview

This project focuses on exploring and analyzing COVID-19 data using SQL. The analysis examines COVID-19 cases, deaths, infection rates, and vaccination data across different countries and continents.

The project demonstrates practical SQL skills, including data exploration, data cleaning, joins, CTEs, temporary tables, window functions, aggregate functions, views, and data type conversion.

## Skills Used

* SQL Joins
* Common Table Expressions (CTEs)
* Temporary Tables
* Window Functions
* Aggregate Functions
* Views
* Data Type Conversion
* Data Cleaning

## Analysis Performed

### 1. Initial Data Exploration

Explored the COVID-19 deaths dataset and selected key columns for analysis:

* Location
* Date
* Total Cases
* New Cases
* Total Deaths
* Population

### 2. Data Cleaning

Handled zero values in the `total_cases` column to avoid divide-by-zero errors during percentage calculations.

### 3. Total Cases vs. Total Deaths

Calculated the death percentage based on total COVID-19 cases and total deaths.

```sql
(Total Deaths / Total Cases) * 100
```

### 4. Total Cases vs. Population

Calculated the percentage of each country's population that was infected with COVID-19.

```sql
(Total Cases / Population) * 100
```

### 5. Countries with the Highest Infection Rate

Identified countries with the highest infection counts and calculated the percentage of their population infected with COVID-19.

### 6. Countries with the Highest Death Count

Identified countries with the highest recorded total COVID-19 death counts.

### 7. Breakdown by Continent

Analyzed COVID-19 death counts across different continents.

### 8. Global COVID-19 Numbers

Calculated global COVID-19 statistics, including:

* Total New Cases
* Total New Deaths
* Global Death Percentage

```sql
(Total New Deaths / Total New Cases) * 100
```

### 9. Population vs. Vaccinations

Joined the COVID-19 deaths and vaccination datasets to analyze vaccination progress.

Used a window function to calculate the rolling total of people vaccinated for each location and calculated the vaccination percentage relative to the population.

```sql
(Rolling People Vaccinated / Population) * 100
```

### 10. Temporary Table

Created a temporary table named `#PercentPopulationVaccinated` to store vaccination-related data for further analysis.

The temporary table includes:

* Continent
* Location
* Date
* Population
* New Vaccinations
* Rolling People Vaccinated

### 11. SQL View for Visualization

Created a reusable SQL view named `PercentPopulationVaccinated`.

The view contains population and vaccination data and can be used for further analysis or visualization in tools such as Tableau or Power BI.

## Database Tables Used

* `CovidDeaths`
* `CovidVaccanations`

## Key SQL Concepts

```sql
JOIN
WITH (CTE)
OVER (PARTITION BY ... ORDER BY ...)
SUM()
MAX()
CAST()
ROUND()
GROUP BY
CREATE TABLE
INSERT INTO
CREATE OR ALTER VIEW
```

## Technologies Used

* SQL Server
* SQL

## Project Structure

```text
covid-sql-analysis/
├── covid_portfolio_project.sql
└── README.md
```

## How to Use

1. Clone this repository.
2. Open SQL Server Management Studio (SSMS) or another SQL Server-compatible environment.
3. Create or select the `PortfolioProject` database.
4. Ensure the `CovidDeaths` and `CovidVaccanations` tables are available.
5. Open `covid_portfolio_project.sql`.
6. Run the SQL queries.

## Author

**Stuti Acharya**

## Project Purpose

This project was created as part of my SQL portfolio to demonstrate practical SQL skills in data exploration and analysis. It showcases the use of SQL to work with real-world data, perform calculations, join datasets, analyze global and country-level statistics, calculate rolling vaccination totals, create temporary tables, and build reusable views for visualization.

