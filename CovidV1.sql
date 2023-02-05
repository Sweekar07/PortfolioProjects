select * from PortfolioProject..CovidDeaths
order by 3,4

select * from PortfolioProject..CovidVacinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;

--Total cases vs Total Deaths
--Shows likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;

-- looking at total cases vs population
select location, date, population, total_cases,(total_cases/population)*100 as Infected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;

--looking at countries with highest infection rate as compared to population
select distinct location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Infected
from PortfolioProject..CovidDeaths
group by location, population
order by Infected desc;

-- showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc;

-- LETs break things down by continent
-- Showing the continents with the highest DeathCounts
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Covid Vaccinations

select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccination
from PortfolioProject..CovidVacinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --option 1 using cte

 with PopvsVac (Continent, loaction, date, population, new_vaccinations, RollingPeopleVaccination)
 as 
 (
 select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccination
from PortfolioProject..CovidVacinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 ) 
 select *, (RollingPeopleVaccination/population) * 100 
 from PopvsVac

 -- Using temp table
 drop table if exists #percentPopulationVaccinated
 create table #percentPopulationVaccinated
 (
 continent nvarchar(255), location nvarchar(255), date datetime, Population numeric, New_vaccination numeric, RollingPeopleVaccination numeric)


 insert into #percentPopulationVaccinated
 select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccination
from PortfolioProject..CovidVacinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location 
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select *, (RollingPeopleVaccination/population) * 100 
 from #percentPopulationVaccinated


 -- Creating view to store data for later viz

create view PercentPopulationVaccinatedd as
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccination
from PortfolioProject..CovidVacinations vac
join PortfolioProject..CovidDeaths dea
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

