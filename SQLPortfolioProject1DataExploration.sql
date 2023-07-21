SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if contracting covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1, 2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2


--Looking at total cases vs population
--Shows percentage of population that contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Countries with the highest infection rate

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
order by InfectionRate Desc

Select Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by population, location
order by PercentPopulationInfected desc

-- Showing Countries with highest deathcount per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by location 
order by TotalDeathCount desc


-- Brokendown by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2


--Total Death Pecentage Globally

Select SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Adding new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- By population Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingTotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingTotalVaccinations/Population)* 100 as Total_vaccination_percentage
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinations numeric,
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingTotalVaccinations/Population)* 100 as Total_vaccination_percentage
From #PercentPopulationVaccinated


--Creating View to store for visualizations

Create View Total_vaccination_percentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- Confirming View Worked

--Total Vaccination Percentage View
Select *
From Total_vaccination_percentage

Create View Deaths_by_continent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
--order by TotalDeathCount desc

--Percent of Population Infected view
Create View PercentPopulationInfected as
Select Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by population, location
--order by PercentPopulationInfected desc

-- Infection Percentage View US
Create View InfectionPercentage as
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
--order by 1,2


--Death Percentage by Country view

Create View DeathPercentage as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--order by 1, 2