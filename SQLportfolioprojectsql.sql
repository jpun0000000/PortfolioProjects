Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3, 4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location like '%states%'
and continent is not null
order by 1, 2

--Looking at total cases vs population
--Shows what percentage of population has gotten covid

Select Location, date, population, total_cases,  (total_cases/population)* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
order by 1, 2

-- Looking at Countries with Highest Infection rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--WHERE location like '%states%'	
Group by Location, population
order by PercentPopulationInfected desc
  

--Showing countries with the highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc 

 --LET'S BREAK THINGS DOWN BY CONTINENT

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by continent
order by TotalDeathCount desc

--Showing contintents with the highest death count



-- Global Numbers

Select  SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NEW_Cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE

With PopvsVac (Continent, Location,  Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

--Temp Table
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

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated


-- Creating View to store for later visualizations

CREATE VIEW PercentPopulationVaccinated as	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
 dea.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 


Select *
From PercentPopulationVaccinated

