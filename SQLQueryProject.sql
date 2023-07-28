/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * FROM PortfolioProject..covidDeaths
ORDER BY 3,4;


--SELECT * FROM PortfolioProject..covidVaccinations
--order by 3,4;

--SELECT DATA WE ARE GOING TO USE

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTACT COVID IN NEPAL
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location = 'NEPAL'
ORDER BY 1,2;

-- LOOKING AT THE TOTAL CASES VS POPULATION
-- Shows what percentage of population infected with Covid
SELECT location, date,population, total_cases, (total_cases/population)*100 as INFECTED_PERCENTAGE
FROM PortfolioProject..covidDeaths
WHERE location = 'NEPAL'
ORDER BY 1,2;


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS Highest_Infection_count, MAX((total_cases/population))*100 as Infected_Percentage
FROM PortfolioProject..covidDeaths
--WHERE location = 'NEPAL'
GROUP BY location, population
ORDER BY 4 DESC;

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) AS Highest_Death_Count, MAX((total_deaths/population))*100 as Death_Percentage
FROM PortfolioProject..covidDeaths
--WHERE location = 'NEPAL'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS Highest_Death_Count, MAX((total_deaths/population))*100 as Death_Percentage
FROM PortfolioProject..covidDeaths
--WHERE location = 'NEPAL'
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- GLOBAL DATA
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_Death_Count, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..covidDeaths
--WHERE location = 'NEPAL'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 ;

-- GLOBAL DATA ON COVID (TOTAL CASES AND DEATHS)
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_Death_Count, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..covidDeaths
--WHERE location = 'NEPAL'
WHERE continent IS NOT NULL

--LOOKING AT TOTAL POPULATION VS  TOTAL VACCINATION GLOBALLY
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(PARTITION BY dea.location) AS Total_vaccinated
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2;

-- TOTAL POPULATION VS TOTAL VACCINATION PER DAY 
-- USING CTE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
WITH CTE 
(Continent, Location, Date, Population, Vaccination, Total_vaccination_perday)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccinated
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Total_vaccination_perday/Population)* 100 AS Percent_vaccinated_daily FROM CTE
ORDER BY 1,2;


-- POPULATION VS VACCINATION WITH TEMP TABLE
CREATE TABLE #PercentPoulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,

Total_vaccinated_perday numeric
)
INSERT INTO #PercentPoulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) over(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccinated_perday
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM #PercentPoulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPoulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) over(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccinated_perday
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPoulationVaccinated;