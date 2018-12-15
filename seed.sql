-- Dummy data for tests
-- https://www.postgresql.org/docs/9.1/sql-insert.html
 -- Countries

INSERT INTO country(name, code)
VALUES ('Germany',
        'DE'), ('France',
                'FR'), ('Great Britan',
                        'GB'), ('United States of America',
                                'US'), ('Japan',
                                        'JP'), ('China',
                                                'CN'), ('South Africa',
                                                        'SA');

 -- Fails - breaks PK constraint

INSERT INTO country(name, code)
VALUES ('Jupiter',
        'CN');

 Founders
INSERT INTO founder(firstname, lastname, dob, country_of_origin)
VALUES ('Elon', 'Musk',
        '1971-28-06',
        'SA') -- Companies

INSERT INTO company(name, founded, country_code, parent_company_id)
VALUES ('Tesla',
        '2003-01-01',
        'US',
        NULL), ('Perbix',
                '1976-01-01',
                'US',
                1), ('SolarCity',
                     '2006-06-04',
                     'US',
                     1), ('Grohmann Engineering',
                          '1963-01-01',
                          'DE',
                          1), ('Riviera Tool LLC',
                               '2007-01-01',
                               'US',
                               1), -- Fails - not_own_parent constraint

INSERT INTO company(name, founded, country_code, parent_company_id)
VALUES ('Foo',
        '2018-12-15',
        'US',
        2);

 --  >> new row for relation "company" violates check constraint "not_own_parent"
 -- Founder Companies

INSERT INTO founder_companies(founder_id, company_id)
VALUES (1,
        1);

 -- Acquisitions

INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date)
VALUES(1,
       2,
       'completed',
       '2017-11-06'),
VALUES(1,
       3,
       'completed',
       '2016-06-22'),
VALUES(1,
       4,
       'completed',
       '2016-11-08'),
VALUES(1,
       5,
       'completed',
       '2015-06-08');

 -- Fails - no_self_acquisitions

INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date)
VALUES(1,
       1,
       'failed',
       '2015-06-08');

 -- Fails - check_no_failed_completion_dates
-- >> new row for relation "acquistion" violates check constraint "check_no_failed_completion_dates"

INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date, completion_date)
VALUES(1,
       6,
       'failed',
       '2015-06-08',
       '2015-06-09');

 -- Fails - acquisition_date_constraint

INSERT INTO acquistion (parent_company_id, child_company_id, announced_date)
VALUES(2,
       6,
       '2018-12-14');

 -- << 2018-12-14 Acquistion cannot be announced before company founded
