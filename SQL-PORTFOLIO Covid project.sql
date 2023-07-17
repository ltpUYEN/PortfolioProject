--Data exploration

--Death-Table's Overview
SELECT *
FROM project1..CovidDeaths
ORDER BY 2,3

--Vaccination-Table's Overview
SELECT *
FROM project1..CovidVaccinations
WHERE continent is not null
ORDER BY 2,3


--Select the target data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

----Looking at Total Cases vs Total Deaths
-----(Look into Vietnam)
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) DeathPercentage
FROM CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

----Looking at Total Cases vs Total Deaths
SELECT location,population, MAX(total_cases) HighestInfectionCount, MAX(ROUND((total_cases/population)*100,2)) PercentagePopulationInfected
FROM CovidDeaths
--WHERE location = 'Vietnam'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

----Showing Contries with Highest Death Count per Population
SELECT location, MAX(CAST(Total_Deaths AS INT)) TotalDeathCount,population, MAX(ROUND((total_deaths/population)*100,2)) PercentagePopulationDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

----showing the continents with the highest deathcount
SELECT continent, MAX(CAST(Total_Deaths AS INT)) TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null

----total_deaths approximately equal to Jamaica's population
SELECT MAX(population), location
FROM CovidDeaths
WHERE 2800000 < population AND population < 3200000
GROUP BY location


--Joining two tables
SELECT *
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date

----Looking at Total population vs Vaccination 
SELECT d.continent, d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT( INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3


--CTE 
WITH Table1 (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT d.continent, d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT( INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3)
)
SELECT *, ROUND((rollingpeoplevaccinated/population)*100,2) peoplevaccinated
FROM Table1

--TEMP Table / 2
DROP TABLE if exists #TableTEMP
CREATE TABLE #TableTEMP
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #TableTEMP
SELECT d.continent, d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT( INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, ROUND((rollingpeoplevaccinated/population)*100,2) Peoplevaccinated
FROM #TableTEMP
ORDER BY 1,2

--CREATE VIEW to store data 
Create View PercentPopulationVaccinated AS
SELECT d.continent, d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT( INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated