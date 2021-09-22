select *
from PortofolioProject1..['COVID Deaths$']
order by 3,4 

--select *
--from PortofolioProject1..COVIDVaccinations$
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject1..['COVID Deaths$']
order by 1,2 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
from PortofolioProject1..['COVID Deaths$']
where location like 'united kingdom'
order by 1,2
-- total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 AS Population_Percentage
from PortofolioProject1..['COVID Deaths$']
where location like 'united kingdom'
order by 5 desc

-- what countries have the highest infection rates compared to population
select location, Population, max(total_cases) as highestpopulationcount, (total_cases/Population)*100 as percentagepopulationinfected
from PortofolioProject1..['COVID Deaths$']
where continent is not null 
group by population, location 
order by 1, 2

-- countries with the highest death count per population
select location, max(total_deaths) as totaldeathcount 
from portofolioProject1..['COVID Deaths$']
where continent is not null
group by location
order by totaldeathcount desc

-- showing continents with the highest death counts per population
select continent, max(total_deaths) as totaldeathcount 
from portofolioProject1..['COVID Deaths$']
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers 
select location, (total_cases) , sum(cast(total_deaths as int)) as total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portofolioProject1..['COVID Deaths$']
where continent is not null
group by date
order by 1, 2

-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from ['COVID Deaths$'] dea
join COVIDVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- number of people vaccinated per country using CTE
with popvsvac (continent, location, date, population, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['COVID Deaths$'] dea
join COVIDVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100 as vaccinatedperpopulation
from popvsvac
order by vaccinatedperpopulation 

-- number of people vaccinated per population using TEMP TABLE
Drop table if exists #percentagepopulation123
create table #percentagepopulation123
(continent nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)

insert into #percentagepopulation123
select dea.continent, dea.date, dea.population, new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['COVID Deaths$'] dea
join COVIDVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 as vaccinatedperpopulation
from #percentagepopulation123

-- creating views to store for later visualizations

create view percentagepopulationvaccinated as 
select dea.continent, dea.date, dea.population, new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['COVID Deaths$'] dea
join COVIDVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




