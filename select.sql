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


a) select * from company where founded > 1999-12-31;

b) select * from company where country_code IN ('UK', 'US');

c) select distinct(a.parent_company_id) from (select * from acquisition where status == 'completed')a;

d) select a.founder_id from (select count(founder_id) from founder_companies)a where count >=3;

e) select a.child_company_id from (select * from acquisition where status == 'failed')a join (select * from acquisition where status == 'completed')b where a.failed_date < b.complete_date;

f) select a.founder_id from (select count(*) as cn from founder_companies group by founder_id order by cn desc)a limit 10;

g)


