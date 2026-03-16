CREATE SCHEMA pandemic;
USE pandemic;

SELECT COUNT(*) FROM infectious_cases;

-- 2
CREATE TABLE countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL,
    UNIQUE KEY unique_entity_code (entity, code)
);

INSERT INTO countries (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases
WHERE Entity IS NOT NULL AND Code IS NOT NULL;

SELECT COUNT(*) AS total_countries FROM countries;
SELECT * FROM countries;

CREATE TABLE cases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT NOT NULL,
    year INT NOT NULL,
    number_yaws FLOAT NULL,
    polio_cases FLOAT NULL,
    cases_guinea_worm FLOAT NULL,
    number_rabies FLOAT NULL,
    number_malaria FLOAT NULL,
    number_hiv FLOAT NULL,
    number_tuberculosis FLOAT NULL,
    number_smallpox FLOAT NULL,
    number_cholera_cases FLOAT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(id),
    INDEX idx_year (year)
);

INSERT INTO cases (
    country_id,
    year,
    number_yaws,
    polio_cases,
    cases_guinea_worm,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
SELECT 
    c.id,
    i.Year,
    NULLIF(i.Number_yaws, ''),
    NULLIF(i.polio_cases, ''),
    NULLIF(i.cases_guinea_worm, ''),
    NULLIF(i.Number_rabies, ''),
    NULLIF(i.Number_malaria, ''),
    NULLIF(i.Number_hiv, ''),
    NULLIF(i.Number_tuberculosis, ''),
    NULLIF(i.Number_smallpox, ''),
    NULLIF(i.Number_cholera_cases, '')
FROM infectious_cases i
JOIN countries c ON i.Entity = c.entity AND i.Code = c.code;

SELECT COUNT(*) AS total_cases FROM cases;
SELECT * FROM cases;

-- 3
SELECT 
    cnt.entity,
    cnt.code,
    AVG(c.number_rabies) AS avg_rabies,
    MIN(c.number_rabies) AS min_rabies,
    MAX(c.number_rabies) AS max_rabies,
    SUM(c.number_rabies) AS sum_rabies
FROM cases c
JOIN countries cnt ON c.country_id = cnt.id
WHERE c.number_rabies IS NOT NULL
GROUP BY cnt.entity, cnt.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- 4
SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) AS start_of_year,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(YEAR, DATE(CONCAT(year, '-01-01')), CURDATE()) AS year_difference
FROM cases
LIMIT 10;

-- 5
DELIMITER $$

DROP FUNCTION IF EXISTS year_difference$$

CREATE FUNCTION year_difference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE result INT;
    SET result = TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    );
    RETURN result;
END$$

DELIMITER ;

SELECT 
    year,
    year_difference(year) AS diff_years
FROM cases
LIMIT 10;