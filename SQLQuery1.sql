Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select  Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you have COVID in the United States
Select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows the percentage of the population got COVID in the United States
Select  Location, date, total_cases, population, (total_cases/population)*100 as TotalCasesPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

-- What countries have the highest infection rate compared to population?
Select  Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentInfectionRate
From [Portfolio Project]..CovidDeaths
Group by Location, population
order by PercentInfectionRate desc

-- Showing the countries with the highest death count per population
Select  Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breaking things down by continent
Select  Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing the continents with the highest death count
Select  Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by Continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccination/population) * 100
From PopvsVac
order by location

--Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccination numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccination/population) * 100
From #PercentPopulationVaccinated
order by location

-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
Order by Location
