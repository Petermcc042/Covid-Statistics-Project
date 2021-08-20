-- Select * From CovidDeathsProject..CovidDeaths order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeathsProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract the virus in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeathsProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
FROM CovidDeathsProject..CovidDeaths
Where location like '%Kingdom%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeathsProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
-- we cast because the total deaths is an nvarchar not an int
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeathsProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing highest deaths by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeathsProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Death Percentage per cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidDeathsProject..CovidDeaths
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total population Vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeathsProject..CovidDeaths dea
Join CovidDeathsProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- using a CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeathsProject..CovidDeaths dea
Join CovidDeathsProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
Where location like '%kingdom%'
order by 2,3

-- using a temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeathsProject..CovidDeaths dea
Join CovidDeathsProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
Where location like '%kingdom%'
order by 2,3


-- Creating a view to store data for later visualisations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeathsProject..CovidDeaths dea
Join CovidDeathsProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
