-- Project Objectives
-- Part - 1 SQL Queries:
-- Task 1: Identifying Approval Trends
-- 1. Determine the number of drugs approved each year and provide insights into the yearly trends.
SELECT YEAR(ActionDate) AS Year,COUNT(*) AS NumberOfApprovals
FROM fda.RegActionDate
WHERE ActionType = 'AP'-- and YEAR(ActionDate) is not NULL
GROUP BY YEAR(ActionDate)
ORDER BY Year;

-- 2. Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.
-- Lowest Approvals
SELECT YEAR(ActionDate) AS Year,  COUNT(*) AS NumberOfApprovals
FROM fda.RegActionDate
WHERE ActionType = 'AP'-- and YEAR(ActionDate) is not NULL
GROUP BY YEAR(ActionDate)
ORDER BY NumberOfApprovals asc limit 3;

-- Higest Approval
SELECT YEAR(ActionDate) AS Year, COUNT(*) AS NumberOfApprovals
FROM ( select *,    
               row_number() over(partition by applNo order by actionDate desc) as rn
               from
               fda.regactiondate 
       ) t
WHERE t.rn = 1 AND ActionType = 'AP'-- and YEAR(ActionDate) is not NULL
GROUP BY YEAR(ActionDate)
ORDER BY NumberOfApprovals desc limit 3;

-- 3. Explore approval trends over the years based on sponsors. 
SELECT YEAR(rad.ActionDate) AS Year, COUNT(rad.applno) AS NumberOfApprovals, a.sponsorapplicant as sponsors
FROM fda.RegActionDate rad  inner join fda.application a on rad.applno=a.applno
WHERE rad.ActionType = 'AP'
GROUP BY YEAR(rad.ActionDate),a.sponsorapplicant
ORDER BY Year,NumberOfApprovals desc; 

-- 4. Rank sponsors based on the total number of approvals they received each year between 1939 and 1960.
SELECT YEAR(rad.ActionDate) AS Year, COUNT(rad.applno) AS NumberOfApprovals, a.sponsorapplicant as sponsors,
dense_rank() over ( partition by YEAR(rad.ActionDate) order by  COUNT(rad.applno) desc ) as ranks
FROM fda.RegActionDate rad inner join fda.application a on rad.applno=a.applno
WHERE rad.ActionType = 'AP' and YEAR(rad.ActionDate) between 1939 and 1960
GROUP BY YEAR(rad.ActionDate), sponsors
ORDER BY Year, ranks;

-- Task 2: Segmentation Analysis Based on Drug MarketingStatus
-- 1. Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.
select count(*) as NoOfProducts,productMktStatus as MarketingStatus from fda.product
group by productMktStatus;

-- 2. Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. 
select count(*) as NoOfApplication,p.productMktStatus as MarketingStatus ,YEAR(rad.ActionDate) AS Year from fda.product p join fda.regactiondate rad on p.applno=rad.applno
where YEAR(rad.ActionDate)>2010
group by Year,MarketingStatus
order by Year,MarketingStatus;

-- 3. Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.
select count(*) as NoOfApplication,p.productMktStatus as MarketingStatus ,YEAR(rad.ActionDate) AS Year from fda.product p join fda.regactiondate rad on p.applno=rad.applno
group by Year,MarketingStatus
order by NoOfApplication desc limit 1;

select count(*) as NoOfApplication,YEAR(rad.ActionDate) AS Year from fda.product p join fda.regactiondate rad on p.applno=rad.applno
where p.productMktStatus =
(select p.productMktStatus  from fda.product p join fda.regactiondate rad on p.applno=rad.applno
group by p.productMktStatus
order by count(*) desc limit 1)
group by Year
order by Year;

-- Task 3: Analyzing Products

-- 1. Categorize Products by dosage form and analyze their distribution.
select  count(*) as NoOfproducts,form from fda.product
group by form
order by NoOfproducts;
-- 2. Calculate the total number of approvals for each dosage form and identify the most successful forms.

SELECT COUNT(*) AS NumberOfApprovals,p.form
FROM fda.RegActionDate rgd join fda.product p on rgd.applno=p.applno
where rgd.ActionType='AP'
GROUP BY p.form
ORDER BY NumberOfApprovals desc;

-- 3. Investigate yearly trends related to successful forms. 
SELECT YEAR(rgd.ActionDate) AS Year, COUNT(*) AS NumberOfApprovals,p.Form
FROM fda.RegActionDate rgd join fda.product p on rgd.applno=p.applno
where rgd.ActionType='AP'
GROUP BY p.form,year
ORDER BY year,NumberOfApprovals desc;

-- Task 4: Exploring Therapeutic Classes and Approval Trends
-- 1. Analyze drug approvals based on the therapeutic evaluation code (TE_Code).
SELECT COUNT(*) AS NumberOfApprovals ,p.TECode
FROM  fda.product p 
JOIN fda.RegActionDate rgd on p.applno=rgd.applno
where rgd.ActionType='AP' and p.TECode is not null
GROUP BY p.TECode
ORDER BY NumberOfApprovals desc;
-- 2. Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.
SELECT YEAR(r.ActionDate) AS Year, p.TECode, COUNT(*) AS NumberOfApprovals,
       RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(*) DESC) AS Ranks
FROM fda.Product p
JOIN fda.RegActionDate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY YEAR(r.ActionDate), p.TECode
ORDER BY Year, Ranks;
-- select * from  appdoc;
-- select * from appdoctype_lookup;
-- select * from application;
-- select * from chemtypelookup; 
-- select * from doctype_lookup;
-- select * from product;
-- select * from product_tecode;
-- select * from regactiondate;
-- select * from reviewclass_lookup;
