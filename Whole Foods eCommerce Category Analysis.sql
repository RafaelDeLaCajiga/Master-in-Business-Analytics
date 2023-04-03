USE bos_ddmban_sql_analysis;

/* 
To find the anwer if the "badges" used by Whole Foods have an impact on the price we need to first separate the samples
by the variable of badge or lack of badge given by "sum_badges".
With that, we can take the average and standard deviation.
*/

SELECT 
		distinct (category), 
		(type_of_badge), 
        ROUND(AVG(regular_price),2) AS `Average Prices`, 
        ROUND(stddev(regular_price),2) AS `Standard Deviation`
FROM ( -- Create the "No Bage" and "Badge" values to unify products with in the categories
	SELECT 
		*,
		(CASE 
			WHEN sum_badges = 0 THEN 'No_Badges'
			WHEN sum_badges > 0 THEN 'With_Badge'
		END) as 'type_of_badge' 
		FROM bmbandd_data) AS prices
GROUP BY category, type_of_badge

		UNION -- Adding the totals at the end of the table

SELECT 'Totals', 
		(type_of_badge), 
        ROUND(AVG(regular_price),2), 
        ROUND(stddev(regular_price),2)
FROM (
	SELECT 
		*,
		(CASE 
			WHEN sum_badges = 0 THEN 'No_Badges'
			WHEN sum_badges > 0 THEN 'With_Badge'
		END) as 'type_of_badge' 
		FROM bmbandd_data) AS prices
GROUP BY type_of_badge
;
/* The reult of this query shows the differences by category and as a whole (Totals). 
Looking at the Totals, one would assume that the products with badges actually have higher average prices than those without.
Due to this it was required to run a hypothesis test in Excel.
*/

-- AVG price per amount of badges-- 
SELECT category, format(AVG(regular_price),2) AS AVG_price, format(AVG(sum_badges),2) AS AVG_Amount_badges
FROM bmbandd_data
WHERE sum_badges > 0
GROUP BY category 
ORDER BY AVG(regular_price) DESC;

-- Top 10 categories with more than 30 products in which the price x badge within the category is the highest --
SELECT *
FROM (
SELECT 
    category,
    COUNT(wf_product_id) AS total_products,
    Round(AVG(regular_price), 2) AS AVG_price,
    ROUND(AVG(sum_badges), 2) AS AVG_Amount_badges,
    ROUND(AVG(regular_price)/AVG(sum_badges),2) AS Avg_price_per_badge
FROM
    bmbandd_data
WHERE
    sum_badges > 0
group by category
) AS sub
ORDER BY Avg_price_per_badge DESC
LIMIT 10
;


-- There are not so many supplements, but with in the category, Sports Nutrition has the most samples.

SELECT category, subcategory, COUNT(data_entry_order)
FROM bmbandd_data
WHERE category LIKE 'supplements'
GROUP BY subcategory, category;
