Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contracted COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From PortfolioProject..CovidDeaths$
Where location like '%zambia%'
order by 1,2

--Looking at the Total Cases vs Popuplation

Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths$
--Where location like '%zambia%'
order by 1,2

--Looking at countries with the highest infection rates

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%zambia%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries w/ Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotaDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
--Where location like '%zambia%'
Group by location
order by TotaDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotaDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
--Where location like '%zambia%'
Group by continent
order by TotaDeathCount desc

--Showing the continent with the highest deathcount




--GLOBAL NUMBERS

Select sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%zambia%'
Where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
From PercentPopulationVaccinated