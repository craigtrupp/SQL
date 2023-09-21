---- New Companies - Advanced Select - Medium Difficulty
-- Given the table schemas below, write a query to print the company_code, 
-- founder name, total number of lead managers, total number of senior managers, 
-- total number of managers, and total number of employees. Order your output by 
-- ascending company_code.

-- Note:

-- The tables may contain duplicate records.
-- The company_code is string, so the sorting should not be numeric. F
-- or example, if the company_codes are C_1, C_2, and C_10, then the ascending 
-- company_codes will be C_1, C_10, and C_2.
/*
Enter your query here.
*/
SELECT
    join_path.company_code, join_path.founder,
    COUNT(DISTINCT join_path.lead_manager) AS lead_managers,
    COUNT(DISTINCT join_path.senior_manager) AS senior_managers,
    COUNT(DISTINCT join_path.manager) AS managers,
    COUNT(DISTINCT join_path.employee) AS employees
FROM 
(
    SELECT
        cmp.company_code AS company_code, cmp.founder AS founder, lm.lead_manager_code AS lead_manager, 
        sm.senior_manager_code AS senior_manager, mng.manager_code AS manager, emp.employee_code AS employee
    FROM Company AS cmp
    INNER JOIN Lead_Manager AS lm
        USING(company_code)
    INNER JOIN Senior_Manager AS sm
        USING(company_code)
    INNER JOIN Manager AS mng
        USING(company_code)
    INNER JOIN Employee AS emp
        USING(company_code)
    ORDER BY cmp.company_code
) AS join_path
GROUP BY join_path.company_code, join_path.founder
ORDER BY join_path.company_code;
