-- 1. Year-wise Trend of Rice Production Across States (Top 3 can be filtered later)
SELECT year, state_name, SUM(rice_production_tons) AS total_rice
FROM icrisat_agriculture
GROUP BY year, state_name
ORDER BY year, total_rice DESC;

-- 2. Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
WITH base AS (
  SELECT dist_name, state_name, year, AVG(wheat_yield_kg_per_ha) AS yield
  FROM icrisat_agriculture
  WHERE year IN  (
    (SELECT MAX(year) FROM icrisat_agriculture),
    (SELECT MAX(year) - 5 FROM icrisat_agriculture)
  )
  GROUP BY dist_name, state_name, year
)
SELECT b1.dist_name, b1.state_name, 
       (b1.yield - b0.yield) AS yield_increase
FROM base b0
JOIN base b1 ON b0.dist_name = b1.dist_name AND b0.year < b1.year
ORDER BY yield_increase DESC
LIMIT 5;

-- 3. States with the Highest Growth in Oilseed Production (5-Year Growth Rate)
WITH base AS (
  SELECT state_name, year, SUM(oilseeds_production) AS prod
  FROM icrisat_agriculture
  WHERE year IN (
    (SELECT MAX(year) FROM icrisat_agriculture),
    (SELECT MAX(year) - 5 FROM icrisat_agriculture)
  )
  GROUP BY state_name, year
)
SELECT b1.state_name, 
       ROUND((b1.prod - b0.prod) / b0.prod * 100, 2) AS growth_rate
FROM base b0
JOIN base b1 ON b0.state_name = b1.state_name AND b0.year < b1.year
ORDER BY growth_rate DESC
LIMIT 5;

-- 4. District-wise Correlation Between Area and Production for Major Crops
SELECT dist_name, state_name, year, 
       rice_area_ha, rice_production_tons,
       wheat_area_ha, wheat_production_tons,
       maize_area, maize_production
FROM icrisat_agriculture
WHERE rice_area_ha IS NOT NULL AND rice_production_tons IS NOT NULL
   OR wheat_area_ha IS NOT NULL AND wheat_production_tons IS NOT NULL
   OR maize_area IS NOT NULL AND maize_production IS NOT NULL;

-- 5. Yearly Production Growth of Cotton in Top 5 Cotton Producing States
WITH top_states AS (
  SELECT state_name
  FROM icrisat_agriculture
  GROUP BY state_name
  ORDER BY SUM(cotton_production) DESC
  LIMIT 5
)
SELECT year, state_name, SUM(cotton_production) AS cotton_total
FROM icrisat_agriculture
WHERE state_name IN (SELECT state_name FROM top_states)
GROUP BY year, state_name
ORDER BY year, cotton_total DESC
LIMIT 5;

-- 6. Districts with the Highest Groundnut Production in 1969
SELECT dist_name, state_name, groundnut_production
FROM icrisat_agriculture
WHERE year = 1969
ORDER BY groundnut_production DESC
LIMIT 5;

-- 7. Annual Average Maize Yield Across All States
SELECT year, ROUND(AVG(maize_yield), 2) AS avg_yield
FROM icrisat_agriculture
GROUP BY year
ORDER BY year;

-- 8. Total Area Cultivated for Oilseeds in Each State
SELECT state_name, SUM(oilseeds_area) AS total_oilseed_area
FROM icrisat_agriculture
GROUP BY state_name
ORDER BY total_oilseed_area DESC;

-- 9. Districts with the Highest Rice Yield (Latest Year)
SELECT dist_name, state_name, rice_yield_kg_per_ha
FROM icrisat_agriculture
WHERE year = (SELECT MAX(year) FROM icrisat_agriculture)
ORDER BY rice_yield_kg_per_ha DESC
LIMIT 10;

-- 10. Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
WITH top_states AS (
  SELECT state_name
  FROM icrisat_agriculture
  GROUP BY state_name
  ORDER BY SUM(rice_production_tons + wheat_production_tons) DESC
  LIMIT 5
)
SELECT year, state_name,
       SUM(rice_production_tons) AS rice_total,
       SUM(wheat_production_tons) AS wheat_total
FROM icrisat_agriculture
WHERE state_name IN (SELECT state_name FROM top_states)
GROUP BY year, state_name
ORDER BY year;

