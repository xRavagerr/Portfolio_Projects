SELECT *
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [Portfolio Projects].[dbo].[CovidVaccinations]
--ORDER BY 3,4



----Select data we want
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects].[dbo].[CovidDeaths]
ORDER BY 1,2




--Total Cases vs Total Deaths -> Death Percentage
SELECT location,date, total_cases,  total_deaths, (Total_deaths/total_cases)  * 100 AS DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
ORDER BY 3 DESC

--Death Percentage in US and in Poland
SELECT location,date, total_cases,  total_deaths, (Total_deaths/total_cases)  * 100 AS DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE location LIKE '%states%'
ORDER BY 3 DESC

SELECT location,date, total_cases,  total_deaths, (Total_deaths/total_cases)  * 100 AS DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE location LIKE 'Poland'
ORDER BY 3 DESC




--Total Cases vs Population -> Likelihood of contracting Covid
SELECT location,date, total_cases,  population, (total_cases/population)  * 100 AS PercentPopulationInfected
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE location LIKE 'Poland'
ORDER BY 5 DESC


--Country with highest infection rate
SELECT location , population , MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected                                                                          
FROM [Portfolio Projects].[dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY 4 DESC



--Countries with Highest Death Count 
SELECT location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount                                                                          
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


----Breakdown by Continent
SELECT location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount                                                                          
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount                                                                          
--FROM [Portfolio Projects].[dbo].[CovidDeaths]
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC


--Global Stats per day
SELECT  date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2 DESC


--Global stats 
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1,2



--Rolling number of vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
JOIN [Portfolio Projects].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	ORDER BY 2,3

--Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
JOIN [Portfolio Projects].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
JOIN [Portfolio Projects].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
WHERE RollingPeopleVaccinated IS NOT NULL




--Create View for Data Visualisations 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
JOIN [Portfolio Projects].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

