--SELECT * 
--FROM PortfolioProject..Covid_Deaths
--ORDER BY 3,4
--USE PortfolioProject;

--Select the data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
ORDER BY 1,2


--looking at Total cases vs total deaths
--likelihood of dying
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location='Canada'
ORDER BY 1,2


-- looking at Total Cases vs Population
-- percentage of population affected by Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CountryCasesPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location = 'canada'
ORDER BY 1,2


--looking at Countries with highest infection rates compared to population
SELECT location, population, continent, MAX(total_cases) AS HighestCaseCount, MAX(total_cases/population)*100 AS TotalCasesPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location = 'canada'
WHERE continent IS NOT NULL
GROUP BY Location, Population, Continent
ORDER BY 5 DESC


-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location = 'canada'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Group by continent
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location = 'canada'
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location = 'canada'
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..Covid_Deaths
--WHERE location='Canada'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Looking at the Totol Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by d.Location ORDER BY d.location, d.Date)as RollingPeopleVaccinated --add bigint to byass the overflow error with int
FROM PortfolioProject..Covid_Deaths d
JOIN PortfolioProject..Covid_Vaccinations vac
	ON d.date=vac.date
	and d.location = vac.location
WHERE d.continent IS NOT NULL 
Order BY 2,3


-- Use CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT d.continent, d.location, d.date, d.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by d.Location ORDER BY d.location, d.Date)as RollingPeopleVaccinated --add bigint to byass the overflow error with int
FROM PortfolioProject..Covid_Deaths d
JOIN PortfolioProject..Covid_Vaccinations vac
	ON d.date=vac.date
	and d.location = vac.location
WHERE d.continent IS NOT NULL 
--Order BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT d.continent, d.location, d.date, d.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by d.Location ORDER BY d.location, d.Date)as RollingPeopleVaccinated --add bigint to byass the overflow error with int
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..Covid_Deaths d
JOIN PortfolioProject..Covid_Vaccinations vac
	ON d.date=vac.date
	and d.location = vac.location
--WHERE d.continent IS NOT NULL 
--Order BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating a view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint )) OVER (Partition by d.Location ORDER BY d.location, d.Date)as RollingPeopleVaccinated --add bigint to byass the overflow error with int
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..Covid_Deaths d
JOIN PortfolioProject..Covid_Vaccinations vac
	ON d.date=vac.date
	and d.location = vac.location
WHERE d.continent IS NOT NULL 
--Order BY 2,3

SELECT * 
FROM PercentPopulationVaccinated