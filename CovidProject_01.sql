
select *
from [portfolio project- covid ] ..CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project- covid ] ..CovidDeaths
order by 1,2 

-- looking at total cases vs total deaths - helps understand the likelihood of dying if you got infected among countries  

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [portfolio project- covid ] ..CovidDeaths
Where location like '%states%'  
order by 1,2 

-- looking at total cases vs population 
-- shows what percentage of the population got covid 

 select location, date, population,  total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from [portfolio project- covid ] ..CovidDeaths
Where location like '%Jordan%'  
order by 1,2 

--- looking at countries with highest infection rate compared to population 

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
from [portfolio project- covid ] ..CovidDeaths
Group by location, population -- why ? to take them country by country 
order by PercentPopulationInfected desc

-- showing countries with highest death count per population 
select location, MAX(cast (Total_deaths as int)) as TotalDeathCount -- total deaths column data type need to be casted as int 
from [portfolio project- covid ] ..CovidDeaths
where continent is not null
Group by location, population 
order by TotalDeathCount desc

-- lets see the result by continent 

select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount -- total deaths column data type need to be casted as int 
from [portfolio project- covid ] ..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers 

select  date, SUM (new_cases) as total_cases , SUM (cast (new_deaths as int)) as total_deaths, SUM ( cast( new_deaths as int )) / SUM(new_cases) *100
as DeathPercentage 
from [portfolio project- covid ] ..CovidDeaths 
where continent is not null
Group by date 
order by 1,2 

-- working with vaccination table 
-- looking at total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) 
from [portfolio project- covid ]..CovidDeaths dea
join [portfolio project- covid ]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 

-- use CTE 

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated 
from [portfolio project- covid ]..CovidDeaths dea
join [portfolio project- covid ]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- temp table 

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated 
from [portfolio project- covid ]..CovidDeaths dea
join [portfolio project- covid ]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- creating a view to store data for later visualizations 

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated 
from [portfolio project- covid ]..CovidDeaths dea
join [portfolio project- covid ]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 

select * 
from  PercentPopulationVaccinated
