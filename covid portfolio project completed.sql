SELECT *
FROM portfolio_projects.dbo.CovidDeaths
ORDER BY 3,4



SELECT *
FROM portfolio_projects.dbo.CovidVaccination
ORDER BY 3,4



--pulling up all data that needed for analysis

Select location, date, total_cases, total_deaths, new_cases, population
FROM portfolio_projects.dbo.CovidDeaths
ORDER BY 1,2


--Total cases Vs total deaths percentage in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
  AS Deathpercentage
FROM portfolio_projects.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Showing the percentage of the population that have gotten covid

Select location, date, total_cases, population, (total_cases/population)*100
   AS percentagepositive
FROM portfolio_projects.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--looking at countries with highest number of reported cases

Select location,max(total_cases) as countInfected , population, MAX(total_cases/population)*100 
  AS percentagepositive
FROM portfolio_projects.dbo.CovidDeaths
GROUP BY location, population
ORDER BY percentagepositive desc


--showing countries with highest death rate vs population

Select location, max(cast(total_deaths as int)) as Deathcount
FROM portfolio_projects.dbo.CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY deathcount desc


--showing death rete by continent

Select continent, max(cast(total_deaths as int)) as Deathcount
FROM portfolio_projects.dbo.CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY deathcount desc


--GLOBAL NUMBERS
-- shows the total number of cases vs total number of deaths per day

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
  sum(cast(new_deaths as int)) / sum(new_cases) *100 as deathpercentage
FROM portfolio_projects.dbo.CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2 

--showing the total number of cases and deaths till date

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
  sum(cast(new_deaths as int)) / sum(new_cases) *100 as deathpercentage
FROM portfolio_projects.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2 


--LOOKING AS VACCINATED NUMBER VS DEATHS

--Joining the two tables

Select *
FROM portfolio_projects.dbo.covidDeaths DEA
JOIN portfolio_projects.dbo.covidVaccination VAC
  ON dea.location = vac.location
  AND dea.date =vac.date

--looking at total number vaccinated people around the world

Select dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
  , dea.date) as countpeoplevaccinated
FROM portfolio_projects.dbo.covidDeaths DEA
JOIN portfolio_projects.dbo.covidVaccination VAC
  ON dea.location = vac.location
  AND dea.date =vac.date
Where dea.continent is not null
ORDER BY 2,3


--using cte

with popvsvac (continent, location, date, population, new_vaccination, countpeoplevaccinated) as 
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
  , dea.date) as countpeoplevaccinated
FROM portfolio_projects.dbo.covidDeaths DEA
JOIN portfolio_projects.dbo.covidVaccination VAC
  ON dea.location = vac.location
  AND dea.date =vac.date
Where dea.continent is not null
)
Select * ,(countpeoplevaccinated/population)*100
from popvsvac


--creating a temp table

Create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
countpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
  , dea.date) as countpeoplevaccinated
FROM portfolio_projects.dbo.covidDeaths DEA
JOIN portfolio_projects.dbo.covidVaccination VAC
  ON dea.location = vac.location
  AND dea.date =vac.date
Where dea.continent is not null
ORDER BY 2,3

Select * ,(countpeoplevaccinated/population)*100
from #percentpopulationvaccinated



--Creating view for visualization

Create view percentagepopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
  , dea.date) as countpeoplevaccinated
FROM portfolio_projects.dbo.covidDeaths DEA
JOIN portfolio_projects.dbo.covidVaccination VAC
  ON dea.location = vac.location
  AND dea.date =vac.date
Where dea.continent is not null
