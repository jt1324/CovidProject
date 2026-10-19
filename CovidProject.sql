-- *************** CREATING TABLE TO EXPORT DATA ******************


-- CREATE TABLE covid_deaths (
--     iso_code                            VARCHAR(20),
--     continent                           VARCHAR(50),
--     location                            VARCHAR(100),
--     date                                DATE,
--     population                          BIGINT,
--     total_cases                         NUMERIC,
--     new_cases                           NUMERIC,
--     new_cases_smoothed                  NUMERIC,
--     total_deaths                        NUMERIC,
--     new_deaths                          NUMERIC,
--     new_deaths_smoothed                 NUMERIC,
--     total_cases_per_million             NUMERIC,
--     new_cases_per_million               NUMERIC,
--     new_cases_smoothed_per_million      NUMERIC,
--     total_deaths_per_million            NUMERIC,
--     new_deaths_per_million              NUMERIC,
--     new_deaths_smoothed_per_million     NUMERIC,
--     reproduction_rate                   NUMERIC,
--     icu_patients                        NUMERIC,
--     icu_patients_per_million            NUMERIC,
--     hosp_patients                       NUMERIC,
--     hosp_patients_per_million           NUMERIC,
--     weekly_icu_admissions               NUMERIC,
--     weekly_icu_admissions_per_million   NUMERIC,
--     weekly_hosp_admissions              NUMERIC,
--     weekly_hosp_admissions_per_million  NUMERIC
-- );

-- ******************** ADJUSTING DATA FORMATING ***************************
-- ALTER DATABASE "PortfolioProject" SET datestyle = 'ISO, DMY';


-- CREATE TABLE covid_vaccinations (
--     iso_code                                VARCHAR(20),
--     continent                               VARCHAR(50),
--     location                                VARCHAR(100),
--     date                                    DATE,
--     new_tests                               NUMERIC,
--     total_tests                             NUMERIC,
--     total_tests_per_thousand                NUMERIC,
--     new_tests_per_thousand                  NUMERIC,
--     new_tests_smoothed                      NUMERIC,
--     new_tests_smoothed_per_thousand         NUMERIC,
--     positive_rate                           NUMERIC,
--     tests_per_case                          NUMERIC,
--     tests_units                             VARCHAR(100),
--     total_vaccinations                      NUMERIC,
--     people_vaccinated                       NUMERIC,
--     people_fully_vaccinated                 NUMERIC,
--     new_vaccinations                        NUMERIC,
--     new_vaccinations_smoothed               NUMERIC,
--     total_vaccinations_per_hundred          NUMERIC,
--     people_vaccinated_per_hundred           NUMERIC,
--     people_fully_vaccinated_per_hundred     NUMERIC,
--     new_vaccinations_smoothed_per_million   NUMERIC,
--     stringency_index                        NUMERIC,
--     population_density                      NUMERIC,
--     median_age                              NUMERIC,
--     aged_65_older                           NUMERIC,
--     aged_70_older                           NUMERIC,
--     gdp_per_capita                          NUMERIC,
--     extreme_poverty                         NUMERIC,
--     cardiovasc_death_rate                   NUMERIC,
--     diabetes_prevalence                     NUMERIC,
--     female_smokers                          NUMERIC,
--     male_smokers                            NUMERIC,
--     handwashing_facilities                  NUMERIC,
--     hospital_beds_per_thousand              NUMERIC,
--     life_expectancy                         NUMERIC,
--     human_development_index                 NUMERIC
-- );


-- ******************** CHECKING AND TESTS ***************************

select * from covid_deaths
order by 3,4;

-- select * from covid_vaccinations
-- order by 3,4;


-- ******************** SELECTING THE DATA THAT WILL BE USED IN THE PROJECT ***************************

SELECT 
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM covid_deaths
ORDER BY 1, 2;


-- ******************** TOTAL CASES vs TOTAL DEATHS ***************************
-- ******************** SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY ***************************

SELECT 
	Location,
	date,
	total_cases,
	total_deaths,
	ROUND((total_deaths / total_cases)*100, 2) AS death_percentage
FROM covid_deaths
-- WHERE Location ilike '%states%'
ORDER BY 1, 2;


-- ******************** TOTAL CASES vs TOTAL POPULATION ***************************
-- ******************** SHOWS THE PERCENTAGE OF THE POPULATION CONTRACT COVID ***************************

SELECT 
	Location,
	date,
	population,
	total_cases,
	ROUND((total_cases / population)*100, 2) AS cases_percentage
FROM covid_deaths
-- WHERE Location ilike '%kingd%'
ORDER BY 1, 2;


-- ******************** SHOWS COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARE TO POPULATION ***************************

WITH data_1 AS(
	WITH data AS(
		SELECT 
			Location,
			date,
			population,
			total_cases,
			ROUND((total_cases / population)*100, 2) AS cases_percentage
		FROM covid_deaths
		ORDER BY 1, 2)
	SELECT
		Location,
		MAX (cases_percentage) AS percent
	FROM data
	GROUP BY Location
	)
SELECT 
	* 
FROM data_1
WHERE percent IS NOT NULL
ORDER BY percent DESC;


-- ******************** SHOWS COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION ***************************

WITH data AS(
	SELECT 
		Location,
		MAX(total_deaths) AS total_death_count
	FROM covid_deaths
	WHERE continent IS NOT NULL
	GROUP BY Location)
SELECT 
	* 
FROM data
WHERE total_death_count IS NOT NULL
ORDER BY total_death_count DESC;


-- ******************** BREAKING BY CONTINENTS ***************************
-- ******************** SHOWS CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION ***************************

WITH data AS(
	SELECT 
		Location,
		MAX(total_deaths) AS total_death_count
	FROM covid_deaths
	WHERE continent IS NULL AND location <> 'World'
	GROUP BY Location)
SELECT 
	* 
FROM data
WHERE total_death_count IS NOT NULL
ORDER BY total_death_count DESC;


-- ******************** GLOBAL NUMBERS ***************************

SELECT 
	date,
	SUM(new_cases) AS new_c,
	SUM(new_deaths)AS deaths,
	ROUND(SUM(new_deaths) / SUM(new_cases)*100, 2) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;



-- ******************** TOTAL POPULATION vs TOTAL VACCINATIONS ***************************

WITH data AS (
	SELECT 
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) 	
			OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
	FROM covid_deaths d
	JOIN covid_vaccinations v
		USING(location, date)
	WHERE d.continent IS NOT NULL
	ORDER BY 2, 3)
SELECT
	*,
	ROUND((rolling_people_vaccinated / population)*100, 2) AS percentage_of_vaccination
FROM data;



-- ******************** TEMP TABLE ***************************

DROP TABLE IF EXISTS PercentPopulationVaccination;
CREATE TABLE PercentPopulationVaccination
(
continent 				  VARCHAR(255),
location 				  VARCHAR(255),
date 					  DATE,
population 				  NUMERIC,
new_vaccinations 		  NUMERIC,
rolling_people_vaccinated NUMERIC
);


INSERT INTO PercentPopulationVaccination
SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) 	
		OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
	USING(location, date)
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

SELECT
	*,
	ROUND((rolling_people_vaccinated / population)*100, 2) AS percentage_of_vaccination
FROM PercentPopulationVaccination;



-- ******************** CREATING VIEW TO STORE DATA FOR VISUALISATIONS ***************************

CREATE VIEW PercentPopulationVaccinated AS 
	SELECT 
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) 	
			OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
	FROM covid_deaths d
	JOIN covid_vaccinations v
		USING(location, date)
	WHERE d.continent IS NOT NULL;


SELECT 
	*
FROM PercentPopulationVaccinated;


