
--SELECT * FROM COVIDvax$

SELECT * FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select the data that will be used.
--SELECT location, date, total_cases, total_deaths, population 
--FROM COVIDdeaths$
--ORDER BY 1,2

--Looking at Total Cases vs Total Deaths In 'x' location
SELECT location, date, total_cases, total_deaths,(CONVERT(FLOAT,total_deaths)/CONVERT(FLOAT,total_cases))*100 AS DeathPercentage
FROM ProtfolioProject..COVIDdeaths$
WHERE location='United States'
ORDER BY 1,2

--Total Cases vs Population. Shows % of population that god COVID for 'x' location
SELECT location, date, total_cases, population,(CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population))*100 AS PrecentOfPopulationInfected
FROM ProtfolioProject..COVIDdeaths$
WHERE location='United States'
ORDER BY 1,2


--Looking at Countries with highest infection rate compared to population
SELECT location, population,MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population))*100 AS PrecentOfPopulationInfected
FROM ProtfolioProject..COVIDdeaths$
--WHERE location='United States'
GROUP BY location,population
ORDER BY PrecentOfPopulationInfected DESC


--Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS	

--USE NULLIF to avoid 'Divide by 0 error'
SELECT date, SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int)) AS TotalDeaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentageGlobally
FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Total Cases, Deaths, and Percentages Globally
SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int)) AS TotalDeaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentageGlobally
FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


--Now using the COVIDvax$ Table
SELECT * FROM ProtfolioProject..COVIDvax$

--Join vax and death tables
SELECT * FROM ProtfolioProject..COVIDdeaths$ dea
JOIN ProtfolioProject..COVIDvax$ vax
	ON dea.location=vax.location
	AND dea.date=vax.date


--Total population vs Vax
SELECT dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
FROM ProtfolioProject..COVIDdeaths$ dea
JOIN ProtfolioProject..COVIDvax$ vax
	ON dea.location=vax.location
	AND dea.date=vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CREATE A TEMP TABLE USING RollingVaccinationNumber column using CTE
WITH PopvsVax(continent,location, date, population, new_vaccinations,RollingVaccinationNumber)
AS(
SELECT dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
FROM ProtfolioProject..COVIDdeaths$ dea
JOIN ProtfolioProject..COVIDvax$ vax
	ON dea.location=vax.location
	AND dea.date=vax.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinationNumber/population)*100 AS PercentagedVaccinated
FROM PopvsVax
--WHERE location='United States'


--CREATE A TEMP TABLE USING RollingVaccinationNumber column using temp table
--Always add DROP TABLE IF EXISTS in order to make changes in the future
DROP TABLE IF EXISTS #PercentagePopulationVaccinated 

CREATE TABLE #PercentagePopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationNumber numeric)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
FROM ProtfolioProject..COVIDdeaths$ dea
JOIN ProtfolioProject..COVIDvax$ vax
	ON dea.location=vax.location
	AND dea.date=vax.date
WHERE dea.continent IS NOT NULL
SELECT *, (RollingVaccinationNumber/population)*100 AS PercentagedVaccinated
FROM #PercentagePopulationVaccinated


--Creating a VIEW to store data for visualizations
CREATE VIEW RollingVaccinations AS
SELECT dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumber
FROM ProtfolioProject..COVIDdeaths$ dea
JOIN ProtfolioProject..COVIDvax$ vax
	ON dea.location=vax.location
	AND dea.date=vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


--Looking at Total Cases vs Total Deaths In 'x' location
CREATE VIEW TotalCasevsTotalDeaths AS
SELECT location, date, total_cases, total_deaths,(CONVERT(FLOAT,total_deaths)/CONVERT(FLOAT,total_cases))*100 AS DeathPercentage
FROM ProtfolioProject..COVIDdeaths$
WHERE location='United States'


CREATE VIEW CasesVsPopulation AS
SELECT location, date, total_cases, population,(CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population))*100 AS PrecentOfPopulationInfected
FROM ProtfolioProject..COVIDdeaths$
WHERE location='United States'



CREATE VIEW HighestInfectionRate AS
SELECT location, population,MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(FLOAT,total_cases)/CONVERT(FLOAT,population))*100 AS PrecentOfPopulationInfected
FROM ProtfolioProject..COVIDdeaths$
--WHERE location='United States'
GROUP BY location,population
--ORDER BY PrecentOfPopulationInfected DESC


CREATE VIEW HighestDeathCountPerPopulation AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS	
CREATE VIEW DeathPercentageGlobal AS
SELECT date, SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int)) AS TotalDeaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentageGlobally
FROM ProtfolioProject..COVIDdeaths$
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY 1,2


