--PostgreSQL 9.6

CREATE TYPE ISO3166_ALPHA2 AS ENUM (
    'DE',
    'FR',
    'GB',
    'US',
    'JP',
    'CN',
    'SA',
    'UK'
);

CREATE TYPE AQUISITION_STATUS AS ENUM (
    'announced',
    'completed',
    'failed'
);

-- Not NF violation as the PK is the code.
DROP TABLE IF EXISTS country CASCADE;
CREATE TABLE country (
    name varchar (255)  not null,
    code ISO3166_ALPHA2 not null,
    PRIMARY KEY (code)
);

DROP TABLE IF EXISTS company;
CREATE TABLE company (
    id serial,
    name varchar (255)  not null,
    founded date not null,
    country_code ISO3166_ALPHA2 not null,
    parent_company_id int default null, -- need to make this an int not a serial to allow nulls

    -- Constraints
    PRIMARY KEY (id),
    CONSTRAINT company_name_country UNIQUE (name, country_code),
    FOREIGN KEY (country_code) REFERENCES country (code),
    FOREIGN KEY (parent_company_id) REFERENCES company (id),
    CONSTRAINT not_own_parent CHECK (id != parent_company_id)
);


CREATE TABLE founder (
    id serial,
    firstname varchar (255) not null,
    lastname varchar (255) not null,
    dob date not null,
    country_of_origin ISO3166_ALPHA2 not null,
    PRIMARY KEY (id),
    FOREIGN KEY (country_of_origin) REFERENCES country (code)
);

CREATE TABLE founder_companies(
    founder_id serial,
    company_id serial,
    FOREIGN KEY (founder_id) REFERENCES founder (id),
    FOREIGN KEY (company_id) REFERENCES company (id)
);

CREATE TABLE acquistion (
    parent_company_id int not null,
    child_company_id int not null,
    status AQUISITION_STATUS,
    price_usd NUMERIC default null,
    announced_date DATE not null,
    completion_date DATE default null,
    FOREIGN KEY (parent_company_id) REFERENCES company (id),
    FOREIGN KEY (child_company_id) REFERENCES company (id),
    CONSTRAINT no_zero_acquisitions CHECK (price_usd > 0),


    -- If an acquisition is failed it must not have a completion date
    CONSTRAINT check_completion_date CHECK (completion_date >= announced_date),

    -- A company cannot acquire itself
    CONSTRAINT no_self_acquisitions CHECK (parent_company_id <> child_company_id),

    -- No completion date for failed acquisitions
    CONSTRAINT check_no_failed_completion_dates CHECK (
        status <> 'failed'
        or status = 'failed' AND (completion_date IS NULL))
);

CREATE FUNCTION acquisition_date_constraint() RETURNS trigger AS $acquisition_date_constraint$
    BEGIN
        IF NEW.announced_date < (SELECT founded FROM company WHERE id = NEW.child_company_id) THEN
            RAISE EXCEPTION '% Acquistion cannot be announced before company founded!', NEW.announced_date;
        END IF;

        RETURN NEW;
    END;
$acquisition_date_constraint$ LANGUAGE plpgsql;

-- Run the trigger whenever a row is inserted or upated to acquisitions
CREATE TRIGGER acquisition_date_constraint BEFORE INSERT OR UPDATE ON acquistion
    FOR EACH ROW EXECUTE PROCEDURE acquisition_date_constraint();


INSERT INTO country(name, code)
VALUES ('Germany',
        'DE'), ('France',
                'FR'), ('Great Britan',
                        'GB'), ('United States of America',
                                'US'), ('Japan',
                                        'JP'), ('China',
                                                'CN'), ('South Africa',
                                                        'SA');

INSERT INTO founder(firstname, lastname, dob, country_of_origin)
VALUES ('Elon', 'Musk',
        '1971-06-28',
        'SA');

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
                               1);

INSERT INTO founder_companies(founder_id, company_id)
VALUES (1,1),
(1,2),
(1,3);

INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date)
VALUES(1,
       2,
       'completed',
       '2017-11-06'),
(1,
       3,
       'completed',
       '2016-06-22'),
(1,
       4,
       'completed',
       '2016-11-08'),
(1,
       5,
       'completed',
       '2015-06-08');

INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date, completion_date)
VALUES(1,
       2,
       'completed',
       '2017-11-06',
       '2017-11-06'),
(1,
       3,
       'completed',
       '2016-06-22',
       '2017-11-06'),
(1,
       4,
       'completed',
       '2016-11-08',
       '2017-11-06'),
(1,
       5,
       'completed',
       '2015-06-08',
       '2017-11-06');

-- Test data for query d
INSERT INTO acquistion (parent_company_id, child_company_id, status, announced_date)
VALUES(1,
       5,
       'failed',
       '2015-06-07');

INSERT INTO founder(firstname, lastname, dob, country_of_origin)
VALUES ('Bobby', 'George',
        '1971-06-28',
        'GB');
 INSERT INTO founder_companies(founder_id, company_id)
VALUES (2,2);

INSERT INTO company(name, founded, country_code, parent_company_id)
VALUES ('Joey',
        '2003-01-01',
        'US',
        NULL),
('Georgie',
        '2003-01-01',
        'US',
        2),
('Petey',
        '2003-01-01',
        'US',
        7);


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

