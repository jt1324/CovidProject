# COVID-19 Data Analysis: SQL & Power BI

An end-to-end data analysis project exploring global COVID-19 cases, deaths and vaccinations from **January 2020 to April 2021**. The data was explored and transformed in **PostgreSQL (pgAdmin)**, and the results were visualised in an interactive **Power BI** dashboard.

## Project Overview

The aim of this project was to practise a full analytics workflow:

1. Import raw data into a PostgreSQL database
2. Explore, clean and transform the data with SQL
3. Load the prepared tables and views into Power BI directly from PostgreSQL
4. Build an interactive dashboard to communicate the findings

## Data Source

The data comes from the [Our World in Data COVID-19 dataset](https://ourworldindata.org/covid-deaths), split into two tables:

- **covid_deaths**: cases, deaths, population and hospitalisation data
- **covid_vaccinations**: testing, vaccination and demographic data

## Tools Used

- **PostgreSQL / pgAdmin**: data import, exploration and transformation
- **Power BI Desktop**: data modelling, DAX measures and visualisation
- **GitHub**: version control and portfolio hosting

## SQL Analysis

The SQL script (`CovidProject.sql`) covers:

- Creating the `covid_deaths` and `covid_vaccinations` tables and setting the database date style (`DMY`) so the CSV dates import correctly
- Choosing the core fields: location, date, cases, deaths and population
- Total cases vs total deaths (the likelihood of dying after contracting COVID in each country)
- Total cases vs population (the percentage of the population infected)
- The countries with the highest infection rate compared to population
- The countries with the highest total death count
- The continents with the highest total death count
- Global daily numbers: new cases, new deaths and death percentage
- Population vs vaccinations, joining both tables and using a window function to calculate a rolling vaccination total per country

**Objects created for Power BI:**

- `PercentPopulationVaccination`: a table storing the rolling vaccination totals
- `PercentPopulationVaccinated`: a view with the rolling vaccination totals by country and date
- `PopulationDeathsVaccinated`: a view combining cases, deaths, vaccinations and the percentage vaccinated

> Note: `new_vaccinations` counts doses given, not individual people, so the vaccination percentage can go above 100% for countries giving more than one dose per person.

**SQL techniques used:** `CREATE TABLE`, joins (`USING`), CTEs, window functions (`SUM() OVER (PARTITION BY ... ORDER BY ...)`), aggregate functions, `GROUP BY`, `ROUND`, `NULL` filtering, and views.

## Power BI Dashboard

The SQL tables and views were imported into Power BI straight from PostgreSQL. The report has four pages:

1. **Overview**: total cases, deaths and vaccinations over time, with a yearly and monthly breakdown table
2. **Total Vaccination**: vaccination totals by continent
3. **Population vs Vaccinations**: population compared with total vaccinated by continent, and vaccination growth from December 2020
4. **People Vaccinated**: people vaccinated over time, plus population and total vaccinated by continent

Each page has a continent slicer (Africa, Asia, Europe, North America, Oceania and South America) for interactive filtering.

![Overview](images/page1.png)
![Total Vaccination](images/page2.png)
![Population vs Vaccinations](images/page3.png)
![People Vaccinated](images/page4.png)

## Key Figures (Jan 2020 – Apr 2021)

| Metric | 2020 | 2021 (Jan–Apr) | Total |
|---|---|---|---|
| Total Cases | 82,735,098 | 67,839,879 | **150,574,977** |
| Total Deaths | 1,824,910 | 1,355,296 | **3,180,206** |
| Total Vaccinations | 1,562,998 | 945,292,137 | **946,855,135** |

## Key Insights

- Cases rose sharply in the second half of 2020, peaking at over 19 million new cases in December 2020.
- Monthly deaths peaked in January 2021 at 411,021.
- Vaccinations began in December 2020 and grew quickly, reaching over 488 million in April 2021 alone.
- Cases dropped in February 2021 but rose again in March and April 2021.

## Repository Structure

├── CovidProject.sql        # SQL queries for data exploration and transformation
├── CovidDashboard.pbix     # Power BI report
├── CovidDashboard.pdf      # Exported PDF of the dashboard
├── images/                 # Dashboard screenshots
└── README.md

## How to Use

1. Download the dataset from Our World in Data and split it into the deaths and vaccinations tables.
2. Run the `CREATE TABLE` statements in `CovidProject.sql`, then import the CSV files through pgAdmin.
3. Run the analysis queries and create the view.
4. Open `CovidDashboard.pbix` in Power BI Desktop and update the PostgreSQL connection to your own database.
