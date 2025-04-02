SELECT *
FROM PotfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PotfolioProject..CovidDeaths$
--ORDER BY 1,2

--Looking at total cases Vs Total Deaths
--Chances of death in South africa
SELECT Location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PotfolioProject..CovidDeaths$
WHERE location like '%South Africa%'and continent is not null
ORDER BY 1,2

--Looking at Total cases Vs Population
-- Displays percentage of the population in South africa got infacted by Covid19
SELECT Location, date, total_cases, population,(total_deaths/total_cases)*100 as DeathPercentage
FROM PotfolioProject..CovidDeaths$
--WHERE location like '%South Africa%' and  continent is not null
ORDER BY 1,2

-- country have the highest infection rate vs population 
SELECT location,population,MAX(total_cases) as HighestInfection ,MAX((total_cases/population))*100 AS InfectedPopulationRate
FROM PotfolioProject..CovidDeaths$
--WHERE location like '%South Africa%' and continent is not null
GROUP BY location,population
ORDER BY InfectedPopulationRate DESC

--Show countries with Highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PotfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break through by continent

--Highest deaths by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PotfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PotfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Cases Per day globally
SELECT SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PotfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2