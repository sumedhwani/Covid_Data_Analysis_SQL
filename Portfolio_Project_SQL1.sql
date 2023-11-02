select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country4
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths$
where location = 'United Kingdom'
order by 1,2	

-- Total Cases vs population
select location,date,population,total_cases, (total_cases/population)*100 as Cases_Percentage
from PortfolioProject.dbo.CovidDeaths$
where location = 'United Kingdom'
order by 1,2

-- Looking at country with highest infection rate compared to population 
select location,population,max(total_cases) as HighestInfection_count, max((total_cases/population))*100 as HighestCase_Percentage
from PortfolioProject.dbo.CovidDeaths$
group by location,population
order by HighestCase_Percentage desc

--Show countries with highest deth count 
select location,max(cast(total_deaths as int)) as HighestDethCount   ----using cast function to convert nvarchar data type of total_deths into int.
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by HighestDethCount desc

--Lets break down by continent
select continent,max(cast(total_deaths as int)) as HighestDethCount   ----using cast function to convert nvarchar data type of total_deths into int.
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by continent
order by HighestDethCount desc

--Global numbers
select date,sum(new_cases) as new_cases_perDay, sum(cast(new_deaths as int)) as new_dethsPerDay, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deth_Percentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null and new_cases is not null and new_deaths is not null   --remove rows with null value from view
group by date
order by 1,2	

--Looking at total population vs Vaccinations

select dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_Vaccinated_tillDate  ---- Converting data type to int of vacc.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ as dea join PortfolioProject.dbo.CovidVaccinations$ as vacc
on dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null and vacc.new_vaccinations is not null
order by 2,3

--Use CTE

with PopulationVSvaccinaition (Continent,location,date,population,new_vaccination,total_Vaccinated_tillDate)
as 
(
select dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_Vaccinated_tillDate  ---- Converting data type to int of vacc.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ as dea join PortfolioProject.dbo.CovidVaccinations$ as vacc
on dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
)
select * ,(total_Vaccinated_tillDate/population)* 100 as Percentage_vaciinated
from PopulationVSvaccinaition
where new_vaccination is not null and total_Vaccinated_tillDate is not null


--Temp table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaciination numeric,
Rollingpeoplevaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_Vaccinated_tillDate  ---- Converting data type to int of vacc.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ as dea join PortfolioProject.dbo.CovidVaccinations$ as vacc
on dea.location = vacc.location and dea.date = vacc.date
--where dea.continent is not null

select * ,(Rollingpeoplevaccinated/population)* 100 as Percentage_vaciinated
from #PercentPopulationVaccinated
where New_vaciination is not null and Rollingpeoplevaccinated is not null


--Createing view to store data later

create view  PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_Vaccinated_tillDate  ---- Converting data type to int of vacc.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ as dea join PortfolioProject.dbo.CovidVaccinations$ as vacc
on dea.location = vacc.location and dea.date = vacc.date
--where dea.continent is not null

select * from PercentPopulationVaccinated