select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccanations
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject ..CovidDeaths
order by 1,2

USE PortfolioProject;

UPDATE dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

--looking at total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
ORDER BY 1, 2;

--looking at the total cases vs the population
SELECT location, date, population,total_cases, 
       (CAST(total_cases AS FLOAT) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
ORDER BY 1, 2;

--looking at countries with highest infection rate compared to population
SELECT 
  location, 
  population, 
  MAX(total_cases) AS HighestInfectionCount, 
  MAX(CAST(total_cases AS FLOAT) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--showing the countries with the highest death count per population
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent
--showing continents with the highest death count per population
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
SELECT 
    --date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--looking at total population vs vaccanations

--use CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccanations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *,
  ROUND((CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100, 2) AS VaccinationPercentage
FROM PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated bigint
);

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccanations vac
  on dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated

--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject..CovidVaccanations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated