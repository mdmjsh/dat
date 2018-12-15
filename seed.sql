-- Dummy data for tests
-- https://www.postgresql.org/docs/9.1/sql-insert.html

-- Countries
INSERT INTO country(name, code)
VALUES ('Germany',
        'DE');


INSERT INTO country(name, code)
VALUES ('France',
        'FR');

INSERT INTO country(name, code)
VALUES ('Great Britan',
        'GB');


INSERT INTO country(name, code)
VALUES ('United States of America',
        'US');


INSERT INTO country(name, code)
VALUES ('Japan',
        'JP');


INSERT INTO country(name, code)
VALUES ('China',
        'CN');

INSERT INTO country(name, code)
VALUES ('South Africa',
        'SA');


-- Fails - breaks PK constraint
-- INSERT INTO country(name, code)
-- VALUES ('Jupiter',
--         'CN');

-- Founders
INSERT INTO founder(name, dob, country_of_origin)
VALUES ('Elon Musk', '1971-28-06', 'SA')


-- Companies
INSERT INTO company(name, founded, country_code)
VALUES ('Tesla', '2003-01-01', 'US');


-- Founder Companies
INSERT INTO founder_companies(founder_id, company_id)
VALUES ('Tesla', '2003-01-01', 'US');

-- Acquisitions

