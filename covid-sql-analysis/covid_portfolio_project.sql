/*
===============================================================================
COVID-19 Data Exploration
Skills used: Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions,
             Views, Data Type Conversion
===============================================================================
*/

USE PortfolioProject;

-- -----------------------------------------------------------------------------
-- 1. Initial look at the data
-- -----------------------------------------------------------------------------
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Select the core columns we'll be working with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

-- -----------------------------------------------------------------------------
-- 2. Data cleaning
-- Avoid divide-by-zero errors in later percentage calculations
-- -----------------------------------------------------------------------------
UPDATE dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

-- -----------------------------------------------------------------------------
-- 3. Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in a given country
-- -----------------------------------------------------------------------------
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY location, date;

-- -----------------------------------------------------------------------------
-- 4. Total Cases vs Population
-- Shows what percentage of the population got COVID
-- -----------------------------------------------------------------------------
SELECT
    location,
    date,
    population,
    total_cases,
    (CAST(total_cases AS FLOAT) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY location, date;

-- -----------------------------------------------------------------------------
-- 5. Countries with the Highest Infection Rate compared to Population
-- -----------------------------------------------------------------------------
SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(CAST(total_cases AS FLOAT) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- -----------------------------------------------------------------------------
-- 6. Countries with the Highest Death Count per Population
-- -----------------------------------------------------------------------------
SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- -----------------------------------------------------------------------------
-- 7. Breakdown by Continent
-- Continents with the highest death count per population
-- -----------------------------------------------------------------------------
SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- -----------------------------------------------------------------------------
-- 8. Global Numbers
-- -----------------------------------------------------------------------------
SELECT
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY TotalNewCases, TotalNewDeaths;

-- -----------------------------------------------------------------------------
-- 9. Total Population vs Vaccinations
-- Rolling count of people vaccinated per country, using a window function
-- -----------------------------------------------------------------------------
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccanations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT
    *,
    ROUND((CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100, 2) AS VaccinationPercentage
FROM PopvsVac
ORDER BY location, date;

-- -----------------------------------------------------------------------------
-- 10. Temp Table version of the above
-- (useful if you need to run further calculations on RollingPeopleVaccinated)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    continent               NVARCHAR(255),
    location                NVARCHAR(255),
    date                    DATETIME,
    population              NUMERIC,
    new_vaccinations        NUMERIC,
    RollingPeopleVaccinated BIGINT
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccanations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated
ORDER BY location, date;

-- -----------------------------------------------------------------------------
-- 11. View for Visualization
-- Creates a reusable view for connecting to Tableau / Power BI
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccanations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;