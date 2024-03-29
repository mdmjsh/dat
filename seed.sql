-- Dummy data for tests
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

 -- Founders
 -- Founders
INSERT INTO founder(firstname, lastname, dob, country_of_origin)
VALUES ('Elon',
        'Musk',
        '1971-06-28',
        'SA'),
        ('Bobby',
        'George',
        '1971-06-28',
        'GB');

 -- Companies
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
                               1)

 -- Fails - not_own_parent constraint
INSERT INTO company(name, founded, country_code, parent_company_id)
VALUES ('Foo',
        '2018-12-15',
        'US',
        6);

 -- Acquisitions
INSERT INTO acquisition (parent_company_id, child_company_id, status, announced_date, completion_date)
VALUES(1, 2,
       'completed',
       '2017-11-06',
       '2017-11-06'),
      (1,3,
      'completed',
      '2016-06-22',
      '2017-11-06'),
      (1, 4,
     'completed',
     '2016-11-08',
     '2017-11-06'),
      (1, 5,
     'completed',
     '2015-06-08',
     '2017-11-06');

 -- Test data for query e
INSERT INTO acquisition (parent_company_id, child_company_id, status, announced_date, failed_date)
VALUES(1,
       5,
       'failed',
       '2015-06-07',
       '2015-06-07');

 -- Fails - no_self_acquisitions
INSERT INTO acquisition (parent_company_id, child_company_id, status, announced_date)
VALUES(1,
       1,
       'failed',
       '2015-06-08');

 -- Fails - check_no_failed_completion_dates
-- >> new row for relation "acquisition" violates check constraint "check_no_failed_completion_dates"
INSERT INTO acquisition (parent_company_id, child_company_id, status, announced_date, completion_date)
VALUES(1,
       6,
       'failed',
       '2015-06-08',
       '2015-06-09');

 --> 23514: new row for relation "acquisition" violates check constraint "check_no_failed_completion_dates"
 -- Fails - acquisition_date_constraint
INSERT INTO acquisition (parent_company_id, child_company_id, announced_date)
VALUES(2,
       5,
       '2006-12-31');
-- << P0001: 2006-12-31 Acquistion cannot be announced before company founded!

-- Test Data for f
INSERT INTO founder_companies(founder_id, company_id)
VALUES (2,
        2);

 -- Test Data for g - test_true should be returned, but not test_false
INSERT INTO company(name, founded, country_code, parent_company_id)
VALUES ('test_false',
        '2003-01-01',
        'US',
        NULL),
        ('test_true',
        '2003-01-01',
        'US',
        2),
        ('test_true_child',
        '2003-01-01',
        'US',
        7);

