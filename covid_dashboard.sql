Select *
FROM covid_portfolio_project..covid_deaths$
WHERE continent is not null 
order by 3,4

--Select *
--FROM covid_portfolio_project..covid_vaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM covid_portfolio_project..covid_deaths$
order by 1,2

-- Location at Total Cases vs Total Deaths
-- Shows likelihood of dying in your country
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_portfolio_project..covid_deaths$
WHERE location like '%emirates%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population has covid
Select Location, date, Population, total_cases,(total_cases/population)*100 as InfectionPopnPercentage
FROM covid_portfolio_project..covid_deaths$
WHERE location like '%indonesia%'
order by 1,2

-- Looking at countries with highest infection rates vs population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPopnPercentage
FROM covid_portfolio_project..covid_deaths$
-- WHERE location like '%indonesia%'
Group by Location, Population
order by InfectionPopnPercentage desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid_portfolio_project..covid_deaths$
WHERE continent is not null 
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as newdeathaspe
FROM covid_portfolio_project..covid_deaths$
WHERE continent is not null
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
-- USE CTE to perform calculation on partition by in previous query 
With popvsVax (Continent, Location, Date, Population, new_vaccinations, rollingpplvax)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as rollingpplvax
From covid_portfolio_project..covid_vaccinations$ vac
Join covid_portfolio_project..covid_deaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (rollingpplvax/population)*100
From popvsvax

-- USING TEMP TABLE 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated  numeric, 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_portfolio_project..covid_deaths$ dea
Join covid_portfolio_project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_portfolio_project..covid_deaths$ dea
Join covid_portfolio_project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- creating view to store data for later vizzes
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_portfolio_project..covid_deaths$ dea
Join covid_portfolio_project..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3