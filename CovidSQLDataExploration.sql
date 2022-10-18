--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--show likelihood of dying if you get covid right now
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as mortality_rate
from PortfolioProject..CovidDeaths
where location='Vietnam'
order by 1,2

--looking at total cases vs population
--show the percent of population that got covid-19
select location,date,total_cases,population,(total_cases/population)*100 as infection_rate
from PortfolioProject..CovidDeaths
where location='Vietnam'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highes_infection_count,max((total_cases/population))*100 as infection_rate
from PortfolioProject..CovidDeaths
group by location,population
order by 4 desc

--showing countries with highest death counts compared to population
select location,max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null -- i do this because some of the location are grouped as the whole continent (not countries)
group by location
order by 2 desc
--now let's break things down with continents
select location,max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is null -- i do this because some of the location are grouped as the whole continent (not countries)
group by location
order by 2 desc
--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_rate
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1;
--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by
 dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
order by 2,3;

--using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by
 dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as vaccination_rate
from PopvsVac;

--TEMP TABLE
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
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by
 dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- creating View to store data for later visualizations
GO
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by
 dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations