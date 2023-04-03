/* 
Authors -  Rishabh, Rafael, Mei
Date - 8th Nov, 2022
Description H-1B visas database analysis
*/

use `rmr_h1b`;

-- Creating the view for requestes

Create View `request` AS
SELECT *
FROM (SELECT `st`.`state_id`, `st`.`state`, sum(`ca`.`total_worker_position`) AS `requests`
FROM `case_applications` AS `ca`
INNER JOIN `states` AS `st` USING (`state_id`)
GROUP BY `st`.`state_id`, `st`.`state`) AS `req`
INNER JOIN `case_applications` AS `c` USING (`state_id`)
INNER JOIN `visa_statuses` AS `vs` USING (`visa_status_id`);

-- Which functions pays the most
SELECT 
    `na`.`industry_title` AS `industry`,
    `so`.`job_type` AS `job`,
    AVG(`wage`) AS `yearly_wage`
FROM
    `case_applications` AS `ca`
        INNER JOIN
    `socs` AS `so` USING (`soc_id`)
        INNER JOIN
    `naics` AS `na` USING (`naics_id`)
GROUP BY `so`.`job_type`, `na`.`industry_title`
ORDER BY `yearly_wage` DESC;

-- Outliers in wage
-- Finding the thresholds

SELECT `wage_quartile`, MAX(`wage`) AS `quartile_break`
FROM (SELECT `employer_name`, `wage`, NTILE(4) OVER (ORDER BY `wage`) AS `wage_quartile`
FROM `case_applications` AS `ca`
INNER JOIN `employers` AS `em` USING (`employer_id`)) AS quartiles
WHERE `wage_quartile` IN (1,3)
GROUP BY `wage_quartile`
;

-- Lower threshold = 76856 , Upper threshold = 114234

-- Finding the job_types with outliers
SELECT DISTINCT
    (`job_type`), COUNT(*) AS `outliers`
FROM
    (SELECT 
        `soc_id`, `wage`
    FROM
        `case_applications`
    WHERE
        `wage` > (170301)) AS `ol`
        INNER JOIN
    `socs` AS `so` USING (`soc_id`)
GROUP BY `job_type`
;

-- creating a check for H1b Dependency
CREATE VIEW `dependency` AS
SELECT `em`.`employer_id`, "Yes" AS dependency_check
FROM `request` AS `rq`
INNER JOIN `employers` AS `em` USING (`employer_id`)
WHERE `rq`.`h1b_dependent` = 1
UNION
SELECT `em`.`employer_id`, "No" AS `dependency_check`
FROM `request` AS `rq`
INNER JOIN `employers` AS `em` USING (`employer_id`)
WHERE `rq`.`h1b_dependent` = 0
AND `em`.`employer_id` NOT IN (
SELECT `em`.`employer_id`
FROM `request` AS `rq`
INNER JOIN `employers` AS `em` USING (`employer_id`)
WHERE `rq`.`h1b_dependent` = 1
);

-- Agent Representation Check
SELECT 
	SUM(agent_representing_employer) / COUNT(case_id)*100 AS `% of Approval with Agent`
FROM 
	case_applications
WHERE visa_status_id = 1001;

-- Top Employer USA
SELECT 
		`na`.`industry_title`, 
		`em`.`employer_name`, 
        `so`.`job_type`, 
        SUM(`rq`.`total_worker_position`) AS `total_request`, 
        ROUND(AVG(`rq`.`wage`),0) AS `average_salary`
FROM `request` AS `rq`
INNER JOIN `socs` as `so` USING (`soc_id`)
INNER JOIN `employers` as `em` USING (`employer_id`)
INNER JOIN `dependency` as `de` USING (`employer_id`)
INNER JOIN `naics` as `na` USING (`naics_id`)
WHERE `de`.`dependency_check` = "Yes"
GROUP BY `na`.`industry_title`, `em`.`employer_name`, `so`.`job_type`
ORDER BY `total_request` DESC
Limit 5;

-- State Wise Approval Rate vs tax rate
SELECT 
	`st`.`state`,
    `st`.`corporate_tax_rate`,
	sum(`total_worker_position`) AS `total_certified`, 
    `requests`, (sum(`total_worker_position`)/`requests`)*100.00 AS `percent_approved`    
FROM `request` AS `rq`
INNER JOIN `states` as `st` USING (`state_id`)
WHERE visa_status = "Certified"
GROUP BY `st`.`state`, `st`.`corporate_tax_rate`, `requests`;

-- Top Employer in Washington State
SELECT 
	`na`.`industry_title`, 
	`em`.`employer_name`, 
    `so`.`job_type`, 
    SUM(`rq`.`total_worker_position`) AS `total_request`, 
    ROUND(AVG(`rq`.`wage`),0) AS `average_salary`
FROM request AS rq
INNER JOIN socs as so USING (soc_id)
INNER JOIN employers as em USING (employer_id)
INNER JOIN dependency as de USING (employer_id)
INNER JOIN naics as na USING (naics_id)
WHERE de.dependency_check = "Yes"
AND rq.state = "WA"
GROUP BY na.industry_title, em.employer_name, so.job_type
ORDER BY total_request DESC
Limit 5;

