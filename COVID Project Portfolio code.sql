SELECT *
FROM PotrfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PotrfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select the data that we are going to be using

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PotrfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases Vs Total Deaths 
-- Shows the likelihood of dying if you contract COVID in a given country 
SELECT 
location,
date,
total_cases,
total_deaths,
(CAST(total_deaths as FLOAT)/CAST(total_cases as FLOAT))*100 AS DeathPercentage
FROM PotrfolioProject..CovidDeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2;


-- Looking at the Total Cases Vs Population
-- What Percentage of the Population has gotten from Covid
SELECT 
location,
date,
population
total_cases,
(CAST(total_cases as FLOAT)/CAST(Population as FLOAT))*100 AS PopulationCaseRate
FROM PotrfolioProject..CovidDeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2;


-- Looking at the Total Deaths Vs Population
-- What Percentage of the Population has died from Covid
SELECT 
location,
date,
population
total_cases,
(CAST(total_deaths as FLOAT)/CAST(Population as FLOAT))*100 AS PopulationDeathRate
FROM PotrfolioProject..CovidDeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2;




-- Looking at Countries with the highest infection rates compared to populations.
SELECT 
location,
population,
MAX(total_cases) AS HighestInfectionCount,
MAX((CAST(total_cases as FLOAT)/CAST(Population as FLOAT)))*100 AS PercentPopulationInfected
FROM PotrfolioProject..CovidDeaths
GROUP BY population,location
ORDER BY  PercentPopulationInfected DESC;


-- Looking at Countries with the highest death rates per populations.
SELECT 
location,
MAX (CAST(total_deaths as int)) AS TotalDeathCount
FROM PotrfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC;

-- Looking at the Data by Continent
--Showing the Continent with the highest Death Count
SELECT 
continent,
MAX (CAST(total_deaths as int)) AS TotalDeathCount
FROM PotrfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC;

--GLOBAL NUMBERS

SELECT 
SUM(new_deaths) AS TotalDeaths,
SUM (new_cases) AS TotalCases,
(SUM(new_deaths)/SUM (new_cases))*100 AS DeathPercentage
FROM PotrfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population Vs Vaccination
SELECT dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVacCount

--(RollingVacCount/population)*100
-- Need to create a CTE
FROM PotrfolioProject..CovidDeaths AS dea
JOIN PotrfolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 
 --AND dea.location LIKE '%Albania%' AND new_vaccinations IS NOT NULL
 ORDER BY 1,2,3

 --USE A CTE
 WITH PopVsVac (location, continent,date,population, new_vaccinations, RollingVacCount)
 AS

(SELECT dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVacCount
 FROM PotrfolioProject..CovidDeaths AS dea
JOIN PotrfolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3
)
SELECT *, (RollingVacCount/population)*100
FROM PopVsVac

--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE 
#PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime ,
Population numeric,
New_Vaccinations numeric, 
RollingVacCount numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVacCount
 FROM PotrfolioProject..CovidDeaths AS dea
JOIN PotrfolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3

SELECT *, (RollingVacCount/population)*100
FROM #PercentPopulationVaccinated


-- Create View to Store Data for Later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVacCount
 FROM PotrfolioProject..CovidDeaths AS dea
JOIN PotrfolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL 
 --ORDER BY 2,3

 SELECT *
 FROM PercentPopulationVaccinated
