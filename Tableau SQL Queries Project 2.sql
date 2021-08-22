-- Queries for tableau visualisation

-- 1. Total deaths to cases ratio

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) * 100 / SUM(new_cases) as DeathPercentage
From CovidDeathsProject..CovidDeaths
where continent is not null
order by 1,2


-- 2. Continent total death count
Select location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From CovidDeathsProject..CovidDeaths
Where continent is null and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3. total worst percentage of population infected per country
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
From CovidDeathsProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- 4. Countries ranked by percent of population infected by date
Select location , population, date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeathsProject..CovidDeaths
Group by location, population, date
order by PercentPopulationInfected desc