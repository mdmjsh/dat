-- casting country code as text

SELECT cast(code AS text)
FROM country;


SELECT cast(country_of_origin AS text)
FROM founder;

 -- Founders of Tesla

SELECT founder.name,
       company.name
FROM founder_companies
JOIN founder ON founder.id = founder_companies.founder_id
JOIN company ON company.id = founder_companies.company_id
WHERE company.name = 'Tesla';

 -- Companies owned by Tesla

SELECT *
FROM company
WHERE parent_company_id = 1;

 -- Same query, but with a self join (imagine we didn't know the company id)

SELECT child.*
FROM company child
JOIN company parent ON child.parent_company_id = parent.id
WHERE parent.name = 'Tesla';

 ----- question 3
 a)
SELECT id
FROM company
WHERE founded > '1999-12-31';

 b)
SELECT id
FROM company
WHERE country_code IN ('UK', 'US');

 c)
SELECT distinct(parent_company_id)
FROM acquistion
WHERE status = 'completed';

 d)
SELECT founder_id,
       COUNT (founder_id)
FROM founder_companies
GROUP BY founder_id HAVING COUNT (founder_id) >= 3;

 e)
SELECT f.child_company_id
FROM
  (SELECT *
   FROM acquistion
   WHERE status = 'failed')f
JOIN
  (SELECT *
   FROM acquistion
   WHERE status = 'completed')c
   ON c.child_company_id = f.child_company_id
WHERE c.completion_date > f.announced_date;

 f)
SELECT founder_id,
       count(founder_id)
FROM founder_companies
GROUP BY founder_id
ORDER BY count(founder_id) DESC LIMIT 10;

 g) WITH RECURSIVE comp AS
  (SELECT parent_company_id,
          id,
          name
   FROM company
   WHERE name = 'Tesla'
   UNION SELECT c.parent_company_id,
                c.id,
                c.name
   FROM company c
   INNER JOIN comp p
   ON p.id = c.parent_company_id)
SELECT comp.name
FROM comp;

