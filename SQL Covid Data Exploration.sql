SELECT *
FROM [Analyst Portfolio Project]..CovidDeaths$
ORDER BY 3,4


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT *
--FROM [Analyst Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

--Select Data we are going to be using

--Looking at Total Cases vs Total Deaths
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Analyst Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Looking  at Total Cases vs  Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Looking at countries with highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 as InfectedPercentage
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY InfectedPercentage DESC



-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Showing Countries with the Highest Death Count per Population and percentage
SELECT location, population, MAX(cast (total_deaths as int)) AS HighestDeathCount, (MAX(cast (total_deaths as int))/population) as HighestDeathPercentage
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY HighestDeathCount DESC



SELECT location, MAX(cast (total_deaths as int)) AS HighestDeathCount
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BREAKING THINGS DOWN BY CONTINENT
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing contintents with the highest death count per population
SELECT location, SUM(cast (total_deaths as int)) AS TotalDeathCount
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT continent, MAX(cast (total_deaths as int)) AS HighestDeathCount
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(cast (new_deaths as int)) AS TotalDeathCount, (SUM(new_cases)/SUM(cast (new_deaths as int)))*100 AS DeathPercentage
FROM [Analyst Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

---- Looking at Total People Vaccinated vs Total Populations
SELECT 
	DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAC.new_vaccinations, 
	SUM(CAST(VAC.new_vaccinations AS INT)) 
	OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM [Analyst Portfolio Project]..CovidDeaths$ DEA
JOIN [Analyst Portfolio Project]..CovidVaccinations$ VAC
ON DEA.location = VAC.location and DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL and VAC.new_vaccinations IS NOT NULL
ORDER by 1,2

----- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAC.new_vaccinations, 
	SUM(CAST(VAC.new_vaccinations AS INT)) 
	OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM [Analyst Portfolio Project]..CovidDeaths$ DEA
JOIN [Analyst Portfolio Project]..CovidVaccinations$ VAC
ON DEA.location = VAC.location and DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL and VAC.new_vaccinations IS NOT NULL
--ORDER by 1,2
)

SELECT *,
(RollingPeopleVaccinated/Population)*100 AS RollingPercentage
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255), 
Location NVARCHAR(255), 
Date NVARCHAR(255), 
Population BigINT, 
New_Vaccinations BigINT, 
RollingPeopleVaccinated Float
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAC.new_vaccinations, 
	SUM(CAST(VAC.new_vaccinations AS INT)) 
	OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM [Analyst Portfolio Project]..CovidDeaths$ DEA
JOIN [Analyst Portfolio Project]..CovidVaccinations$ VAC
ON DEA.location = VAC.location and DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL and VAC.new_vaccinations IS NOT NULL

SELECT *,
(RollingPeopleVaccinated/Population)*100 AS RollingPercentage
FROM #PercentPopulationVaccinated


--Create View to store data for later visualizations
Create VIEW PercentPopulationVaccinated AS
SELECT 
	DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAC.new_vaccinations, 
	SUM(CAST(VAC.new_vaccinations AS INT)) 
	OVER 
	(PARTITION BY DEA.location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM [Analyst Portfolio Project]..CovidDeaths$ DEA
JOIN [Analyst Portfolio Project]..CovidVaccinations$ VAC
ON DEA.location = VAC.location and DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL --and VAC.new_vaccinations IS NOT NULL