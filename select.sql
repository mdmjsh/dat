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


