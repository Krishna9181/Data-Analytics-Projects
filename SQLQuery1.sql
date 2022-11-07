-- Filtering Data
select location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths
order by 1,2;

-- Exploring Total Cases & Total Deaths
select location, date, population, total_cases, new_cases, total_deaths, Round((total_deaths*100/total_cases), 2) as death_percentage
from CovidDeaths
where location like 'India'
order by 1,2;

-- Analyzing percentage of people who got Covid over a period
select location, date, population, total_cases, new_cases, total_deaths, Round((total_cases*100/population), 2) as Covid_Rate
from CovidDeaths
where location like 'India'
order by 1,2;


-- Analyzing country-wise highest covid infection rate
select location, population, max(total_cases) as Maximum_Covid_Cases, Round((max(total_cases)*100/population), 2) as Highest_Infection_Rate
from CovidDeaths
group by location, population
order by Highest_Infection_Rate desc;

-- Showing Countries-wise Highest Death Rate
select location, population, max(total_deaths) as Highest_Deaths, Round((max(total_deaths)*100/population), 2) as Highest_Death_Rate
from CovidDeaths
group by location, population
order by Highest_Death_Rate desc;

-- Showing Global Numbers
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))*100/sum(new_cases) as Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Showing Covid Death Percentage of the World
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))*100/sum(new_cases) as Death_Percentage
from CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total Population vs Total Vaccinations
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations_smoothed,
sum(cast(cv.new_vaccinations_smoothed as int)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from CovidDeaths cd 
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3,4

-- Using CTE
-- Displaying Percentage of Total People Vaccinated as the time Progress
With people_vaccinated (date, continent, location, population, new_vaacinations_smoothed, Total_Vaccinations) 
as 
(select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations_smoothed,
sum(cast(cv.new_vaccinations_smoothed as int)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from CovidDeaths cd 
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)

select *, (Total_Vaccinations/population)*100 as Percentage_Vaccinated 
from people_vaccinated;


-- Creating Views for people_vaccinated
CREATE VIEW people_vaccinated
as
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations_smoothed,
sum(cast(cv.new_vaccinations_smoothed as int)) over (partition by cd.location order by cd.location, cd.date) as Total_Vaccinations
from CovidDeaths cd 
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null;

select * from people_vaccinated;
