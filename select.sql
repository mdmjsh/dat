-- casting country code as text
select cast(code as text)  from country;
select cast(country_of_origin as text)  from founder;


-- Founders of Tesla
select founder.name, company.name from founder_companies
join founder on founder.id = founder_companies.founder_id
join company on company.id = founder_companies.company_id
where company.name = 'Tesla';

-- Companies owned by Tesla
select * from company where parent_company_id = 1;

-- Same query, but with a self join (imagine we didn't know the company id)
select child.* from company child
join company parent
on child.parent_company_id = parent.id
where parent.name = 'Tesla';


----- question 3

a) select id from company where founded > '1999-12-31';

b) select id from company where country_code IN ('UK', 'US');

c) select distinct(parent_company_id) from acquistion where status = 'completed';

d) SELECT
 founder_id,
 COUNT (founder_id)
FROM
 founder_companies
GROUP BY
 founder_id
HAVING
 COUNT (founder_id) >= 3;


e) select f.child_company_id from
 (select * from acquistion where status = 'failed')f
 join (select * from acquistion where status = 'completed')c on c.child_company_id = f.child_company_id
 where c.completion_date > f.failed_date;

f) select founder_id, count(founder_id) from founder_companies
 group by founder_id
 order by count(founder_id) desc limit 10;

g)

WITH RECURSIVE comp AS (
 SELECT
 parent_company_id,
 id,
 name
 FROM
 company
 WHERE
 name = 'Tesla'
 UNION
 SELECT
 c.parent_company_id,
 c.id,
 c.name
 FROM
 company c
 INNER JOIN comp p ON p.id = c.parent_company_id
) SELECT
 comp.name
FROM
 comp;

