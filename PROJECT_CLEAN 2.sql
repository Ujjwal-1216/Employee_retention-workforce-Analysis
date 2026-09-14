
use empl_retention;
CREATE TABLE employee_retention_clean AS
SELECT
    TRIM(`FirstName`) AS first_name,
    TRIM(`LastName`) AS last_name,
    STR_TO_DATE(`StartDate`, '%d-%b-%y') AS start_date,
    STR_TO_DATE(NULLIF(`ExitDate`, ''), '%d-%b-%y') AS exit_date,
    TRIM(`Title`) AS title,
    TRIM(`Supervisor`) AS supervisor,
    TRIM(`ADEmail`) AS email,
    TRIM(`BusinessUnit`) AS business_unit,
    TRIM(`EmployeeStatus`) AS employee_status,
    TRIM(`EmployeeType`) AS employee_type,
    TRIM(`PayZone`) AS pay_zone,
    TRIM(`EmployeeClassificationType`) AS classification_type,
    TRIM(`TerminationType`) AS termination_type,
    TRIM(`TerminationDescription`) AS termination_description,
    TRIM(`DepartmentType`) AS department_type,
    TRIM(`Division`) AS division,
    STR_TO_DATE(`DOB`, '%d-%m-%Y') AS date_of_birth,
    TRIM(`State`) AS state,
    TRIM(`JobFunctionDescription`) AS job_function_description,
    TRIM(`GenderCode`) AS gender,
    `LocationCode` AS location_code,
    TRIM(`RaceDesc`) AS race,
    TRIM(`MaritalDesc`) AS marital_status,
    TRIM(`Performance Score`) AS performance_score,
    `Current Employee Rating` AS current_employee_rating,
    `Employee ID` AS employee_id,
    STR_TO_DATE(`Survey Date`, '%d-%m-%Y') AS survey_date,
    `Engagement Score` AS engagement_score,
    `Satisfaction Score` AS satisfaction_score,
    `Work-Life Balance Score` AS work_life_balance_score,
    STR_TO_DATE(`Training Date`, '%d-%b-%y') AS training_date,
    TRIM(`Training Program Name`) AS training_program_name,
    TRIM(`Training Type`) AS training_type,
    TRIM(`Training Outcome`) AS training_outcome,
    TRIM(`Location`) AS location,
    TRIM(`Trainer`) AS trainer,
    `Training Duration(Days)` AS training_duration_days,
    `Training Cost` AS training_cost,

    CASE
        WHEN TRIM(`EmployeeStatus`) = 'Active'
             AND NULLIF(`ExitDate`, '') IS NOT NULL
            THEN 'Active_with_ExitDate'

        WHEN TRIM(`EmployeeStatus`) IN
             ('Voluntarily Terminated', 'Terminated for Cause')
             AND NULLIF(`ExitDate`, '') IS NULL
            THEN 'Terminated_without_ExitDate'

        ELSE 'Consistent'
    END AS status_exit_flag

FROM employee_retention;

CREATE TABLE employee_retention_clean_new AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   first_name, last_name, start_date, exit_date,
                   title, supervisor, email, business_unit,
                   employee_status, employee_type, pay_zone,
                   classification_type, termination_type,
                   termination_description, department_type, division,
                   date_of_birth, state, job_function_description, gender,
                   location_code, race, marital_status, performance_score,
                   current_employee_rating, employee_id, survey_date,
                   engagement_score, satisfaction_score, work_life_balance_score,
                   training_date, training_program_name, training_type,
                   training_outcome, location, trainer,
                   training_duration_days, training_cost, status_exit_flag
               ORDER BY employee_id
           ) AS rn
    FROM employee_retention_clean
) AS ranked
WHERE rn = 1;

-- Tenure days , Years and overall average tenure

WITH tenure_day AS (
    SELECT
        employee_id,
        start_date,
        exit_date,
        employee_status,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),

tenure_year AS (
    SELECT
        employee_id,
        start_date,
        exit_date,
        employee_status,
        tenure_days,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
)

SELECT * , round(AVG(tenure_years) over(),2) AS avg_tenure_years
FROM tenure_year;

WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),

tenure_year AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        tenure_days,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
)
SELECT department_type ,round(AVG(tenure_years),2) AS avg_tenure_years
FROM tenure_year group by department_type;

-- avg tenure by employee status

WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),

tenure_year AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        tenure_days,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
)
SELECT
    CASE
        WHEN employee_status = 'Active' THEN 'Active'
        ELSE 'Left'
    END AS employee_group,
    ROUND(AVG(tenure_years), 2) AS avg_tenure_years
FROM tenure_year
GROUP BY
    CASE
        WHEN employee_status = 'Active' THEN 'Active'
        ELSE 'Left'
    END;

WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),

tenure_year AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        tenure_days,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
),
tenure_grouped AS (
    SELECT
        employee_id,
        exit_date,
        tenure_years,
        CASE
            WHEN tenure_years < 1 THEN 'low'
            WHEN tenure_years < 2 THEN 'low-mid'
            WHEN tenure_years < 3 THEN 'mid'
            WHEN tenure_years < 5 THEN 'mid-high'
            ELSE 'high'
        END AS tenure_group
    FROM tenure_year
)

SELECT
    tenure_group,
    COUNT(*) AS total_count
FROM tenure_grouped
WHERE exit_date IS NOT NULL
GROUP BY tenure_group; 

WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        exit_date,
        employee_status,
        tenure_days,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
),
tenure_grouped AS (
    SELECT
        employee_id,
          department_type,
        exit_date,
        tenure_years,
        CASE
            WHEN tenure_years < 1 THEN 'low'
            WHEN tenure_years < 2 THEN 'low-mid'
            WHEN tenure_years < 3 THEN 'mid'
            WHEN tenure_years < 5 THEN 'mid-high'
            ELSE 'high'
        END AS tenure_group
    FROM tenure_year
)
SELECT
    department_type,
    tenure_group,
    COUNT(*) AS total_count
FROM tenure_grouped
WHERE exit_date IS NOT NULL
and tenure_years < 1
GROUP BY tenure_group, department_type;


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, employee_status,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, employee_status, tenure_days,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
),
tenure_grouped AS (
    SELECT
        employee_id, department_type, exit_date, tenure_years,
        CASE
            WHEN tenure_years < 1 THEN 'low'
            WHEN tenure_years < 2 THEN 'low-mid'
            WHEN tenure_years < 3 THEN 'mid'
            WHEN tenure_years < 5 THEN 'mid-high'
            ELSE 'high'
        END AS tenure_group FROM tenure_year
)
SELECT
    department_type,
    COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) AS early_exit_count,
    COUNT(*) AS total_employees,
    ROUND(
        COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END)
        / COUNT(*) * 100,
        2
    ) AS early_exit_rate FROM tenure_year GROUP BY department_type;
    
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
),
tenure_grouped AS (
    SELECT
        employee_id, department_type, exit_date, tenure_years, termination_type,
        CASE
            WHEN tenure_years < 1 THEN 'low'
            WHEN tenure_years < 2 THEN 'low-mid'
            WHEN tenure_years < 3 THEN 'mid'
            WHEN tenure_years < 5 THEN 'mid-high'
            ELSE 'high'
        END AS tenure_group FROM tenure_year
)
SELECT
    termination_type, COUNT(*) AS employee_count FROM tenure_year
WHERE exit_date IS NOT NULL
  AND tenure_years < 1
GROUP BY termination_type;

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT case when exit_date IS NOT NULL AND tenure_years < 1 then  "Early Leaver" else "Stay" end as Employee_group ,
    avg(satisfaction_score) as avg_satisfaction_score , avg(engagement_score) as avg_eng_score,
    avg(work_life_balance_score) as avg_work_life_bal from tenure_year
GROUP BY (case when exit_date IS NOT NULL AND tenure_years < 1 then  "Early Leaver" else "Stay" end );


-- employees with lower performance ratings more likely to leave within their first year
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
select performance_score, 
count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end )as early_leavers , 
count(*) as total_employees , 
(count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end ))/count(*)* 100.0 as early_leaver_rate
from tenure_year 
group by performance_score;

-- by employee type

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
select employee_type, 
count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end )as early_leavers , 
count(*) as total_employees , 
(count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end ))/count(*)* 100.0 as early_leaver_rate
from tenure_year 
group by employee_type;

-- Within each department, which performance group has the highest early-exit rate?
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
select department_type, performance_score, 
count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end )as early_leavers , 
count(*) as total_employees , 
(count(case when exit_date IS NOT NULL AND tenure_years < 1 then 1 end ))/count(*)* 100.0 as early_leaver_rate
from tenure_year 
group by department_type, performance_score;


-- How many employees joined the organization each year?

SELECT
    YEAR(start_date) AS year,
    COUNT(employee_id) AS total_employee_joined
FROM employee_retention_clean
GROUP BY YEAR(start_date)
ORDER BY year;

-- How many employees left each year?
SELECT
    YEAR(exit_date) AS year,
    COUNT(employee_id) AS total_employee_left
FROM employee_retention_clean
WHERE exit_date IS NOT NULL
GROUP BY YEAR(exit_date)
ORDER BY year;

-- annual net workforce change

WITH joined_year AS (
    SELECT YEAR(start_date) AS year,COUNT(employee_id) AS total_employee_joined
    FROM employee_retention_clean GROUP BY YEAR(start_date)
),
left_year AS (
    SELECT YEAR(exit_date) AS year, COUNT(employee_id) AS total_employee_left
    FROM employee_retention_clean WHERE exit_date IS NOT NULL GROUP BY YEAR(exit_date)
),
net_rate AS (
    SELECT j.year, j.total_employee_joined, l.total_employee_left,
        j.total_employee_joined - l.total_employee_left AS total_workforce_change
    FROM joined_year j JOIN left_year l ON j.year = l.year
)
SELECT
    year, total_employee_joined, total_employee_left, total_workforce_change,
    ROUND(
        total_workforce_change / total_employee_joined * 100.0,
        2
    ) AS workforce_change_rate FROM net_rate ORDER BY year;
    
    -- by department type ((based on recorded ExitDate))
SELECT
    department_type,employee_type,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END) AS total_dep_exit,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END)/COUNT(*)* 100.0 as dep_exit_rate
FROM employee_retention_clean
GROUP BY department_type , employee_type;   


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT employee_type, AVG(tenure_years) AS avg_tenure_year, COUNT(*) AS total_employees
FROM tenure_year GROUP BY employee_type;

-- Which termination types have the shortest average tenure


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT termination_type,
AVG(tenure_years),
COUNT(*) as total
FROM tenure_year GROUP By termination_type ;


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type, employee_status,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type, employee_status,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT
    termination_type,
    ROUND(AVG(tenure_years), 2) AS avg_tenure_years,
    COUNT(*) AS total
FROM tenure_year
WHERE employee_status IN (
    'Voluntarily Terminated',
    'Terminated for Cause'
)
GROUP BY termination_type;


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type, employee_status,
current_employee_rating,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type, employee_status, current_employee_rating,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT
    current_employee_rating,
    COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) AS early_leavers,
    COUNT(*) AS total_employees,
    ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) / COUNT(*) * 100,2
    ) AS early_leaver_rate
FROM tenure_year
GROUP BY current_employee_rating
ORDER BY current_employee_rating;

SELECT
    YEAR(start_date) AS hiring_year,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END) AS total_left,
    count(case when exit_date is not null then 1 end)/count(*)*100.0 as exit_rate
FROM employee_retention_clean
GROUP BY YEAR(start_date)
ORDER BY hiring_year;

-- Which departments have the highest overall recorded exit rate?
SELECT department_type,
    count(case when employee_status = 'active' then 1 end) as active_employees,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END) AS left_employees,
    count(case when exit_date is not null then 1 end)/count(*)*100.0 as exit_rate
FROM employee_retention_clean
GROUP BY  department_type;

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type, employee_status,
current_employee_rating,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type, employee_status, current_employee_rating,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT
    current_employee_rating,
    COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) AS early_leavers,
    COUNT(*) AS total_employees,
    ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) / COUNT(*) * 100,2
    ) AS early_leaver_rate
FROM tenure_year
GROUP BY current_employee_rating
ORDER BY current_employee_rating;


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,satisfaction_score,
engagement_score, work_life_balance_score,performance_score, employee_type, employee_status,
current_employee_rating,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        satisfaction_score,performance_score, employee_type, employee_status, current_employee_rating,
engagement_score, work_life_balance_score, tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT
    department_type,
    CASE
        WHEN employee_status = 'Active' THEN 'Active'
        ELSE 'Left'
    END AS employee_group,
    round(AVG(tenure_years),2) AS avg_tenure_years
FROM tenure_year
GROUP BY
    department_type,
    CASE
        WHEN employee_status = 'Active' THEN 'Active'
        ELSE 'Left'
    END;

-- percentage of employees have a recorded exit from the organization

select count(*) as total_employees, count(case when exit_date is not null then 1 end ) as exit_employees,
 round(count(case when exit_date is not null then 1 end ) / count(*)*100.0,2) as exit_rate from 
 employee_retention_clean;

-- percentage of recorded exits happen within the first 1, 2, 3, and 5 years of employment
    
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
),
tenure_grouped AS (
    SELECT
        employee_id, department_type, exit_date, tenure_years, termination_type,
        CASE
            WHEN tenure_years < 1 THEN 'low'
            WHEN tenure_years < 2 THEN 'low-mid'
            WHEN tenure_years < 3 THEN 'mid'
            WHEN tenure_years < 5 THEN 'mid-high'
            ELSE 'high'
        END AS tenure_group FROM tenure_year
)
SELECT
    tenure_group,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END) AS exit_employees,
    ROUND(
        COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END)
        /
        SUM(COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END)) OVER ()
        * 100,
        2
    ) AS percentage_of_exits
FROM tenure_grouped
GROUP BY tenure_group
ORDER BY
    CASE tenure_group
        WHEN 'low' THEN 1
        WHEN 'low-mid' THEN 2
        WHEN 'mid' THEN 3
        WHEN 'mid-high' THEN 4
        WHEN 'high' THEN 5
    END;    

-- employees who leave within their first year by department
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT
    department_type,COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) AS early_leavers,
    ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END)/ SUM(COUNT(CASE
	WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1 END) ) OVER () * 100, 2) AS percentage_of_early_leavers
FROM tenure_year GROUP BY department_type;

-- Which departments have both a high early-exit rate AND early leavers

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
)
SELECT department_type, COUNT(*) AS total_employees, COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1
THEN 1 END) AS early_leavers,ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
END) / COUNT(*) * 100.0,2) AS early_exit_rate FROM tenure_year
GROUP BY department_type;

-- unsuccessful training outcomes  vs higher risk of leaving within first year
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years FROM tenure_day
)
select training_outcome, count(*) as total_employees , COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1
THEN 1 END) AS early_leavers,ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
END) / COUNT(*) * 100.0,2) AS early_exit_rate from tenure_year group by training_outcome;


-- Failed or Incomplete training outcomes by department
SELECT
    department_type,
    COUNT(*) AS total_employees,
    COUNT(CASE
        WHEN training_outcome IN ('Failed', 'Incomplete') THEN 1
    END) AS unsuccessful_training,
    ROUND(
        COUNT(CASE
            WHEN training_outcome IN ('Failed', 'Incomplete') THEN 1
        END) / COUNT(*) * 100.0,
        2
    ) AS unsuccessful_training_rate
FROM employee_retention_clean
GROUP BY department_type;

-- Satisfaction Score vs Early Exit

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,satisfaction_score, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,satisfaction_score FROM tenure_day
)
select satisfaction_score , count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by satisfaction_score;

-- engagement_score vs Early Exit.
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,engagement_score, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,engagement_score FROM tenure_day
)
select engagement_score , count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by engagement_score;

-- Work-Life Balance Score vs Early Exit.

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,work_life_balance_score FROM tenure_day
)
select work_life_balance_score , count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by work_life_balance_score;


-- employee_type vs Early Exit
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,employee_type, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,employee_type FROM tenure_day
)
select employee_type , count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by employee_type;

-- Successful vs Unsuccessful Training

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,employee_type, exit_date, termination_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, termination_type, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,employee_type FROM tenure_day
)
SELECT COUNT(*) AS total_employees,
    CASE
    WHEN training_outcome IN ('Passed', 'Completed') THEN 'Successful'
    WHEN training_outcome IN ('Failed', 'Incomplete') THEN 'Unsuccessful'
END AS training_group,
count(case when exit_date is not null AND tenure_years < 1 then 1 end) as early_leavers,
round((count(case when exit_date is not null AND tenure_years < 1 then 1 end)/count(*)*100),2) as
 early_leavers_rate
FROM tenure_year
GROUP BY CASE
    WHEN training_outcome IN ('Passed', 'Completed') THEN 'Successful'
    WHEN training_outcome IN ('Failed', 'Incomplete') THEN 'Unsuccessful' end ;

-- pay zone vs early exit
WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, pay_zone, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,pay_zone FROM tenure_day
)
select pay_zone, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by pay_zone;

-- classification_type vs early exit

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, classification_type, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,classification_type FROM tenure_day
)
select classification_type, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by classification_type;



-- State vs Early Exit

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, state, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,state FROM tenure_day
)
select state, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by state;

-- Job Function vs Early Exit

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, job_function_description, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,job_function_description FROM tenure_day
)
select job_function_description, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by job_function_description;



WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, job_function_description, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,job_function_description FROM tenure_day
)
select job_function_description, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by job_function_description  having count(*)  >= 50  order by early_leaver_rate DESC;


-- gender vs early exit

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date,gender, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,gender FROM tenure_day
)
select gender, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by gender;


WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date,marital_status,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,
        tenure_days / 365.0 AS tenure_years,marital_status FROM tenure_day
)
select marital_status, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by marital_status order by early_leaver_rate DESC;


-- race vs early exit 

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date,race,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,
        tenure_days / 365.0 AS tenure_years,race FROM tenure_day
)
select race, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by race;

-- comparing all findings 

WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        start_date,
        performance_score,
        pay_zone,
        classification_type,
        gender,
        marital_status,
        race,
        employee_type,
        job_function_description,
        training_outcome,
        exit_date,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),

tenure_year AS (
    SELECT
        *,
        tenure_days / 365.0 AS tenure_years
    FROM tenure_day
),

factor_rates AS (

    /* 1. Department */
    SELECT
        'Department' AS factor,
        department_type AS category,
        COUNT(*) AS total_employees,
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END) AS early_leavers,
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        ) AS early_leaver_rate
    FROM tenure_year
    GROUP BY department_type

    UNION ALL

    /* 2. Performance Score */
    SELECT
        'Performance Score',
        performance_score,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY performance_score

    UNION ALL

    /* 3. Training Outcome */
    SELECT
        'Training Outcome',
        training_outcome,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY training_outcome

    UNION ALL

    /* 4. Pay Zone */
    SELECT
        'Pay Zone',
        pay_zone,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY pay_zone

    UNION ALL

    /* 5. Classification Type */
    SELECT
        'Classification Type',
        classification_type,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY classification_type

    UNION ALL

    /* 6. Job Function — only 50+ employees */
    SELECT
        'Job Function',
        job_function_description,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY job_function_description
    HAVING COUNT(*) >= 50

    UNION ALL

    /* 7. Gender */
    SELECT
        'Gender',
        gender,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY gender

    UNION ALL

    /* 8. Marital Status */
    SELECT
        'Marital Status',
        marital_status,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY marital_status

    UNION ALL

    /* 9. Race */
    SELECT
        'Race',
        race,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY race

    UNION ALL

    /* 10. Employee Type */
    SELECT
        'Employee Type',
        employee_type,
        COUNT(*),
        COUNT(CASE
            WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
        END),
        ROUND(
            COUNT(CASE
                WHEN exit_date IS NOT NULL AND tenure_years < 1 THEN 1
            END) / COUNT(*) * 100,
            2
        )
    FROM tenure_year
    GROUP BY employee_type
)

SELECT
    factor,
    MAX(early_leaver_rate) AS highest_rate,
    MIN(early_leaver_rate) AS lowest_rate,
    ROUND(
        MAX(early_leaver_rate) - MIN(early_leaver_rate),
        2
    ) AS rate_difference
FROM factor_rates
GROUP BY factor
ORDER BY rate_difference DESC;

WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, job_function_description, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,job_function_description FROM tenure_day
)
select department_type , job_function_description, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
round(count(case when exit_date is not null and tenure_years < 1 then 1 end)/count(*)*100.0 ,2) as early_leaver_rate
from tenure_year group by job_function_description , department_type having count(*)  >= 50  ORDER BY early_leavers DESC;

 -- avg(tenure ) of early leavers
 
 WITH tenure_day AS (
    SELECT
        employee_id, department_type, start_date,work_life_balance_score, exit_date, job_function_description, training_outcome,
        CASE WHEN exit_date IS NOT NULL
		THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days FROM employee_retention_clean
),
tenure_year AS (
    SELECT
        employee_id, department_type, start_date, exit_date, tenure_days,training_outcome,
        tenure_days / 365.0 AS tenure_years,job_function_description FROM tenure_day
)
select department_type , job_function_description, count(*) as total_employees , 
count(case when exit_date is not null and tenure_years < 1 then 1 end) as early_leavers,
ROUND(AVG(
    CASE
        WHEN exit_date IS NOT NULL AND tenure_years < 1
        THEN tenure_years
    END
), 2) AS avg_tenure_early_leavers
from tenure_year group by job_function_description , department_type having count(*)  >= 50  ORDER BY early_leavers DESC;

-- early tenure band

WITH tenure_day AS (
    SELECT employee_id,start_date,exit_date,
        CASE 
            WHEN exit_date IS NOT NULL THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),
tenure_bands AS (
    SELECT *,
        CASE 
            WHEN tenure_days < 90 THEN 'Onboarding (<3 months)'
            WHEN tenure_days < 180 THEN '3-6 months'
            WHEN tenure_days < 270 THEN '6-9 months'
            WHEN tenure_days < 365 THEN '9-12 months'
        END AS tenure_band
    FROM tenure_day
    WHERE exit_date IS NOT NULL
      AND tenure_days < 365
),
band_counts AS (
    SELECT
        tenure_band,
        COUNT(*) AS early_leavers
    FROM tenure_bands
    GROUP BY tenure_band
)
SELECT
    tenure_band,
    early_leavers,
    ROUND(
        early_leavers / SUM(early_leavers) OVER () * 100.0,
        2
    ) AS early_leavers_rate
FROM band_counts;

-- employees who leave within their first 3 months by department

WITH tenure_day AS (
    SELECT employee_id,start_date,exit_date,department_type,
        CASE 
            WHEN exit_date IS NOT NULL THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),
department_counts AS (
    SELECT
        department_type,
        COUNT(*) AS early_0_3_month_leavers
    FROM tenure_day
    WHERE exit_date IS NOT NULL
      AND tenure_days < 90
    GROUP BY department_type
),
tenure_bands AS (
    SELECT *,
        CASE 
            WHEN tenure_days < 90 THEN 'Onboarding (<3 months)'
            WHEN tenure_days < 180 THEN '3-6 months'
            WHEN tenure_days < 270 THEN '6-9 months'
            WHEN tenure_days < 365 THEN '9-12 months'
        END AS tenure_band
    FROM tenure_day
    WHERE exit_date IS NOT NULL
      AND tenure_days < 365
),
band_counts AS (
    SELECT department_type,
        tenure_band,
        COUNT(*) AS early_leavers
    FROM tenure_bands
    GROUP BY tenure_band
)
SELECT
    department_type,
    early_0_3_month_leavers,
    ROUND(
        early_0_3_month_leavers
        / SUM(early_0_3_month_leavers) OVER () * 100,
        2
    ) AS percentage_of_0_3_month_leavers
FROM department_counts
ORDER BY early_0_3_month_leavers DESC;


WITH tenure_day AS (
    SELECT
        employee_id,
        start_date,
        exit_date,
        department_type,
        job_function_description,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),
production_counts AS (
    SELECT
        job_function_description,
        COUNT(*) AS early_0_3_month_leavers
    FROM tenure_day
    WHERE department_type = 'Production'
      AND exit_date IS NOT NULL
      AND tenure_days < 90
    GROUP BY job_function_description
)
SELECT
    job_function_description,
    early_0_3_month_leavers,
    ROUND(
        early_0_3_month_leavers
        / SUM(early_0_3_month_leavers) OVER () * 100,
        2
    ) AS percentage_of_production_0_3_month_leavers
FROM production_counts
ORDER BY early_0_3_month_leavers DESC;


WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        job_function_description,
        start_date,
        exit_date,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days
    FROM employee_retention_clean
),
production_roles AS (
    SELECT
        job_function_description,
        COUNT(*) AS total_employees,
        COUNT(
            CASE
                WHEN exit_date IS NOT NULL
                     AND tenure_days < 90
                THEN 1
            END
        ) AS early_0_3_month_leavers
    FROM tenure_day
    WHERE department_type = 'Production'
    GROUP BY job_function_description
    HAVING COUNT(*) >= 50
)
SELECT
    job_function_description,
    total_employees,
    early_0_3_month_leavers,
    ROUND(
        early_0_3_month_leavers / total_employees * 100,
        2
    ) AS early_0_3_month_exit_rate
FROM production_roles
ORDER BY early_0_3_month_exit_rate DESC;



WITH tenure_day AS (
    SELECT employee_id, department_type, job_function_description,
        training_outcome, start_date, exit_date,
        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days

    FROM employee_retention_clean
)
SELECT job_function_description, training_outcome,
COUNT(*) AS total_employees,
COUNT(
        CASE
            WHEN exit_date IS NOT NULL
                 AND tenure_days < 90
            THEN 1
        END
    ) AS early_leavers,

    ROUND(
        COUNT(
            CASE
                WHEN exit_date IS NOT NULL
                     AND tenure_days < 90
                THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS early_exit_rate
FROM tenure_day WHERE department_type = 'Production'
  AND job_function_description IN ('Coordinator', 'Manager', 'Engineer'
  )GROUP BY job_function_description, training_outcome
ORDER BY job_function_description, early_exit_rate DESC;


WITH tenure_day AS (
    SELECT
        employee_id,
        department_type,
        job_function_description,
        start_date,
        exit_date,

        CASE
            WHEN exit_date IS NOT NULL
                THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date)
        END AS tenure_days

    FROM employee_retention_clean
),

role_analysis AS (
    SELECT
        department_type,
        job_function_description,

        COUNT(*) AS total_employees,

        COUNT(
            CASE
                WHEN exit_date IS NOT NULL
                     AND tenure_days < 90
                THEN 1
            END
        ) AS early_leavers

    FROM tenure_day

    GROUP BY
        department_type,
        job_function_description
)

SELECT
    department_type,
    job_function_description,
    total_employees,
    early_leavers,

    ROUND(
        early_leavers * 100.0 / total_employees,
        2
    ) AS early_exit_rate

FROM role_analysis

WHERE total_employees >= 50

ORDER BY
    early_exit_rate DESC,
    early_leavers DESC;





WITH tenure_day AS (
    SELECT
        employee_id, department_type, job_function_description, start_date, exit_date,
CASE WHEN exit_date IS NOT NULL THEN DATEDIFF(exit_date, start_date)
            ELSE DATEDIFF(CURDATE(), start_date) END AS tenure_days
FROM employee_retention_clean),
cohort_analysis AS (
    SELECT YEAR(start_date) AS hiring_year, department_type, job_function_description,
COUNT(*) AS total_employees,
COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_days < 90 THEN 1 END ) AS early_leavers
FROM tenure_day
WHERE department_type = 'Production'
AND job_function_description IN ( 'Coordinator', 'Manager', 'Engineer','Laborer','Technician','Foreman','Lineman')
GROUP BY YEAR(start_date), department_type, job_function_description)
SELECT
    hiring_year,job_function_description,total_employees,early_leavers,
ROUND(
        early_leavers * 100.0 / total_employees,2) AS early_exit_rate
FROM cohort_analysis
ORDER BY
    hiring_year, early_exit_rate DESC;
    
    
WITH tenure_day AS (
    SELECT employee_id,department_type,performance_score,start_date,exit_date,
CASE WHEN exit_date IS NOT NULL THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
END AS tenure_days
FROM employee_retention_clean
)
SELECT performance_score, COUNT(*) AS total_employees,
COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_days < 90 THEN 1 END) AS early_leavers,
ROUND(COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_days < 90 THEN 1 END) * 100.0 / COUNT(*),2) AS early_exit_rate
FROM tenure_day
WHERE department_type = 'Production' AND YEAR(start_date) = 2022
GROUP BY performance_score ORDER BY early_exit_rate DESC;

-- Role , total employees , 0–3 month leavers & early-exit rate

WITH tenure_day AS (
    SELECT employee_id, department_type, job_function_description, start_date, exit_date,
CASE WHEN exit_date IS NOT NULL THEN DATEDIFF(exit_date, start_date) ELSE DATEDIFF(CURDATE(), start_date)
END AS tenure_days
FROM employee_retention_clean
),
role_analysis AS (SELECT job_function_description,
COUNT(*) AS total_employees,
COUNT(CASE WHEN exit_date IS NOT NULL AND tenure_days < 90 THEN 1 END ) AS early_leavers
FROM tenure_day WHERE department_type = 'Production'
      AND YEAR(start_date) = 2022
      AND job_function_description IN ('Coordinator','Manager','Engineer','Laborer','Technician','Foreman','Lineman')
GROUP BY job_function_description)
SELECT job_function_description,total_employees,early_leavers,
ROUND(early_leavers * 100.0 / total_employees,2) AS early_exit_rate
FROM role_analysis
ORDER BY early_exit_rate DESC, early_leavers DESC;


SELECT * FROM employee_retention_clean;






