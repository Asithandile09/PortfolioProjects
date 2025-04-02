SELECT *
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
	ON dea.location = vac.location 
	and dea.date = dea.date
WHERE dea.continent is not null
Order by 2,3

-- New vaccines 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
	ON dea.location = vac.location 
	and dea.date = dea.date
WHERE dea.continent is not null
Order by 2,3

-- USE CTE
With PopVsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinted)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
	ON dea.location = vac.location 
	and dea.date = dea.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT * ,(RollingPeopleVaccinted/Population)*100 AS VaccinationRate
FROM PopVsVac

--Temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continet nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
	ON dea.location = vac.location 
	and dea.date = dea.date
WHERE dea.continent is not null
--Order by 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated

--Creating views to store for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    --(RollingPeopleVaccinated/population)*100
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3;

SELECT * FROM dbo.PercentPopulationVaccinated;

USE PotfolioProject;
GO

SELECT * FROM sys.views WHERE name = 'PercentPopulationVaccinated';
USE PotfolioProject;
GO

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM dbo.PercentPopulationVaccinated;

--This view gives total vaccinations per country, useful for maps and bar charts.
CREATE VIEW dbo.TotalVaccinationsByLocation AS
SELECT 
    dea.location, 
    SUM(CAST(vac.new_vaccinations AS BIGINT)) AS TotalVaccinations
FROM PotfolioProject..CovidDeaths$ dea
JOIN PotfolioProject..CovidVacinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location;

SELECT * FROM TotalVaccinationsByLocation;

--Global Vaccination Progress
CREATE VIEW dbo.GlobalVaccinationProgress AS
SELECT 
    date, 
    SUM(CAST(new_vaccinations AS BIGINT)) OVER (ORDER BY date) AS TotalPeopleVaccinated
FROM PotfolioProject..CovidVacinations$
WHERE location = 'World';

SELECT * FROM GlobalVaccinationProgress

--Mortalty rate (death per case)
CREATE VIEW dbo.MortalityRateByLocation AS
SELECT 
    location, 
    SUM(new_cases) AS TotalCases, 
    SUM(Convert(int,new_deaths)) AS TotalDeaths,
    (SUM(CONVERT(int,new_deaths)) * 100.0 / NULLIF(SUM(new_cases), 0)) AS MortalityRate
FROM PotfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location;

select * from MortalityRateByLocation;
