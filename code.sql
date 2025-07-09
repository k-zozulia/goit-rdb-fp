CREATE SCHEMA pandemic;
USE pandemic;

RENAME TABLE infectious_cases TO infectious_cases_src;



CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(50) NOT NULL,
    country_code VARCHAR(10) NOT NULL
);

INSERT INTO countries(entity, country_code)
SELECT DISTINCT entity, code
FROM infectious_cases_src;



CREATE TABLE infectious_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT NOT NULL,
    year YEAR NOT NULL,
    number_yaws INT,
    polio_cases INT,
    cases_guinea_worm INT,
    number_rabies DECIMAL(20,10),
    number_malaria DECIMAL(20,10),
    number_hiv DECIMAL(20,10),
    number_tuberculosis DECIMAL(20,10),
    number_smallpox DECIMAL(20,10),
    number_cholera_cases DECIMAL(20,10),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO infectious_cases(
    country_id, year, number_yaws, polio_cases, cases_guinea_worm,
    number_rabies, number_malaria, number_hiv, number_tuberculosis,
    number_smallpox, number_cholera_cases
)
SELECT
    (SELECT c.country_id
     FROM countries c
     WHERE c.entity = s.entity AND c.country_code = s.code),
    CONVERT(s.year, SIGNED),
    CONVERT(NULLIF(s.number_yaws, ''), UNSIGNED),
    CONVERT(NULLIF(s.polio_cases, ''), SIGNED),
    CONVERT(NULLIF(s.cases_guinea_worm, ''), SIGNED),
    CONVERT(NULLIF(s.number_rabies, ''), DECIMAL(20,10)),
    CONVERT(NULLIF(s.number_malaria, ''), DECIMAL(20,10)),
    CONVERT(NULLIF(s.number_hiv, ''), DECIMAL(20,10)),
    CONVERT(NULLIF(s.number_tuberculosis, ''), DECIMAL(20,10)),
    CONVERT(NULLIF(s.number_smallpox, ''), DECIMAL(20,10)),
    CONVERT(NULLIF(s.number_cholera_cases, ''), DECIMAL(20,10))
FROM infectious_cases_src s;



SELECT c.country_id,
       c.entity,
       c.country_code,
       COUNT(*) total_records,
       AVG(i.number_rabies) avg_number_rabies,
       MIN(i.number_rabies) min_number_rabies,
       MAX(i.number_rabies) max_number_rabies,
       SUM(i.number_rabies) sum_number_rabies
FROM infectious_cases i,
     countries c
WHERE i.country_id = c.country_id
  AND i.number_rabies IS NOT NULL
GROUP BY c.country_id,
         c.entity,
         c.country_code
ORDER BY avg_number_rabies DESC
LIMIT 10;






SELECT 
    year,
    MAKEDATE(CAST(year AS UNSIGNED), 1) AS year_date,
    CURDATE() AS today,
    TIMESTAMPDIFF(YEAR, MAKEDATE(CAST(year AS UNSIGNED), 1), CURDATE()) AS years_difference
FROM infectious_cases
GROUP BY year;







DROP FUNCTION IF EXISTS years_since_year_start;

DELIMITER //

CREATE FUNCTION years_since_year_start(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE date_from_year DATE;
  SET date_from_year = MAKEDATE(input_year, 1);
  RETURN TIMESTAMPDIFF(YEAR, date_from_year, CURDATE());
END //

DELIMITER ;

SELECT 
  year,
  years_since_year_start(year) AS years_difference
FROM infectious_cases
GROUP BY year;