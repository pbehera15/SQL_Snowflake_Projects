/* This project analyzes consumer complaints submitted to the Consumer Financial Protection Bureau(CFPB) to identify key trends and areas of concern.*/

/*QUERY #1: Based on this complaint data, when was the first complaint received?*/
SELECT complaint_id,date_received
FROM complaint_details
ORDER BY date_received;

--QUERY #2: What financial products did we receive the most complaints about?
SELECT 
subproduct,
COUNT(subproduct) AS num_of_subproducts
FROM complaint_details
GROUP BY subproduct
ORDER BY num_of_subproducts DESC;

--QUERY #3: What company received the most complaints about cryptocurrencies?
SELECT 
company_name,
subproduct,
YEAR(date_sent_to_company) AS yr,
COUNT(subproduct) AS num_of_complaints
FROM complaint_details
WHERE subproduct = 'Virtual currency'
AND yr = 2019
GROUP BY company_name,subproduct,yr
ORDER BY num_of_complaints DESC;

/*QUERY #4: Compare the number of complaints received each month with the number of complaints received
in the previous month.*/
SELECT 
MONTH(date_received) AS mnth,
COUNT(*) AS num_of_complaints,
LAG(num_of_complaints)
OVER (
ORDER BY mnth
) AS num_complaints_previos_mnth
FROM complaint_details
WHERE YEAR(date_received)= 2018
GROUP BY mnth;

--QUERY #5: What companies are doing a poor job of responding to complaints in a timely manner?
SELECT 
company_name,
COUNT(*) AS total_num_of_complaints,
COUNT(CASE 
WHEN timely_response = 'FALSE' THEN 1
END) AS untimely_response,
ROUND((untimely_response/total_num_of_complaints)*100,2) AS percentage
FROM complaint_details
GROUP BY company_name
HAVING total_num_of_complaints >= 200
ORDER BY percentage DESC;