-- In this project I am going to dive ino the numbers and analysis of covid-19 world data. We will be looking at what all these numbers are telling us and try to map a story regarding the same. 


--Selecting all of the data from the Covid Deaths file to explore it. 
SELECT * FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL


-- Select the data we will be working on
SELECT location, date, total_cases, new_cases, total_deaths
FROM [Covid Project]..CovidDeaths
ORDER BY 1, 2

-- Looking at the Total Deaths VS Total Cases
-- Shows the likelihood of dying after contracting covid in your country
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as Death_percentage
FROM [Covid Project]..CovidDeaths
WHERE location = 'India'

-- Looking at the Total Cases VS Total Population in India
SELECT location, date, total_cases, population, (total_cases/population)*100 as Case_percentage
FROM [Covid Project]..CovidDeaths
WHERE location = 'India'

--What country has the highest infection rate.
SELECT location, population, MAX(total_cases) as HighestInfectedRate, MAX((total_cases/population))*100 as PercentOfPopulation
FROM [Covid Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfPopulation DESC


--What country has the lowest infection rate.
SELECT location, population, MAX(total_cases) as HighestInfectedRate, MAX((total_cases/population))*100 as PercentOfPopulation
FROM [Covid Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfPopulation ASC

--The total number of deaths in each country. 
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location 
ORDER BY TotalDeathCount DESC

--Let's now break things by continent.

--Showing the continent with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, 
SUM(CAST(new_deaths as INT))/ SUM(new_cases)*100 AS DeathPercent
FROM [Covid Project]..CovidDeaths
ORDER BY TotalCases, TotalDeaths


-- Looking at the Total Vaccinations and Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM
[Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.location = 'Albania'
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
ORDER BY 2, 3


--Use CTE. In CTE the number of columns must be same as in the select query below. The ORDER BY clause is invalid in views, 
--inline functions, derived tables, subqueries, and common table expressions

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM
[Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.location = 'Albania' AND
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--Creating view Percent Population Vaccinated to store data for later visualizations. 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM
[Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.location = 'Albania' AND
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2, 3	

--Create a view for Total Deaths in each country.

CREATE VIEW DeathsEachCountry AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location 
--ORDER BY TotalDeathCount DESC

--Create a view for Total Death in each continent.
CREATE VIEW DeathsEachContinent AS 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent 
--ORDER BY TotalDeathCount DESC