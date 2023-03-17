SELECT *
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select relevant data 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
ORDER BY 1,2

--Analyse total cases per total deaths
--Gives a rough estimate of the probability of dying from the virus in United Kingdom
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths$
WHERE location = 'United Kingdom'
ORDER BY 1,2

--Analysing total cases per population
--illustrates the percentage of the population infected with the virus
SELECT location, date, population, total_cases, (total_cases/population)*100 AS cases_per_population
FROM PortfolioProject..covid_deaths$
WHERE location = 'United Kingdom'
ORDER BY 1,2

--Analysing countries with highest infection per population
SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases/population)*100) AS max_cases_per_population
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_cases_per_population DESC

--Continent with the highest death rate
SELECT continent, MAX(cast(total_deaths as int)) AS highest_deaths
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_deaths DESC

--Continent with the highest death rate -2
SELECT location, MAX(cast(total_deaths as int)) AS highest_deaths
FROM PortfolioProject..covid_deaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_deaths DESC

--Countries with the highest death rate
SELECT location, MAX(cast(total_deaths as int)) AS highest_deaths
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_deaths DESC

--Changing 0 to NULL to solve divide-by-zero error 
UPDATE PortfolioProject..covid_deaths$
SET new_deaths = NULL 
WHERE new_deaths = 0

UPDATE PortfolioProject..covid_deaths$
SET new_cases = NULL 
WHERE new_cases = 0

--Global numbers
SELECT SUM(new_cases) AS world_cases, SUM(new_deaths) AS world_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM PortfolioProject..covid_deaths$
WHERE continent	IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Population per vaccination
WITH PopVac (continent, location, date, population, new_vaccination, sum_of_vaccination) AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS sum_of_vaccination
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (sum_of_vaccination/population) *100 as PopVac_percentage
FROM PopVac

--OR
DROP TABLE IF EXISTS #PopVacPercent
CREATE TABLE #PopVacPercent
(continent nvarchar(225), location nvarchar(225), date datetime, population numeric, new_vacinations numeric, sum_of_vaccination numeric)
INSERT INTO #PopVacPercent
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS sum_of_vaccination
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL

SELECT *, (sum_of_vaccination/population) *100 as PopVac_percentage
FROM #PopVacPercent

CREATE VIEW PopVacPercent AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS sum_of_vaccination
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL

select *
from PopVacPercent