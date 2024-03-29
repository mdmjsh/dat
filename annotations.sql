-- N.b. postgresql used
-- CREATE TABLE table_name (
 -- column_name TYPE column_constraint,
 -- table_constraint table_constraint
-- ) INHERITS existing_table_name;

CREATE TYPE ISO3166_ALPHA2 AS ENUM (
    'DE',
    'FR',
    'GB',
    'SS',
    'US'
);


CREATE TYPE AQUISITION_STATUS AS ENUM (
    'announced'
    'completed',
    'failed'
);


DROP TABLE IF EXISTS company;
CREATE TABLE company (
    id serial,
    name varchar (255)  not null,
    founded date not null,
    country_code char (2) not null,
    parent_company_id serial default null,

    -- Constraints
    CONSTRAINT company_name_country UNIQUE (name, country_code), -- c7
    PRIMARY KEY (id),
    FOREIGN KEY (country_code) REFERENCES country (code),
    CONSTRAINT not_own_parent CHECK (id != parent_company_id) -- c1


    -- N.b. another would be to use company_name_country constraint as a
    -- composite PK, but this leads to redundancy an ineffeciency when used
    -- as an FK or by another constraint

    -- FOREIGN KEY (parent_company_name, parent_company_country_code)
    --     REFERENCES company (name, country_code)
    -- CONSTRAINT not_own_parent UNIQUE
    -- ((name, country_code), (parent_company_name, parent_company_country_code))
)

DROP TABLE IF EXISTS country CASCADE;
CREATE TABLE country (
    name varchar (255)  not null,
    code ISO3166_ALPHA2 not null,
    PRIMARY KEY (code)
);

CREATE TABLE founder (
    -- N.b. no composite keys work as a PK, need an id
    id serial,
    name varchar (255) not null,
    dob date not null,
    country_of_origin ISO3166_ALPHA2 not null,
    PRIMARY KEY (id),
    FOREIGN KEY (country_of_origin) REFERENCES country (code)
);

CREATE TABLE acquistion (
    parent_company_id serial not null,
    child_company_id serial not null,
    -- An acquisition has to be announced for it to be in this table
    -- hence default value
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
        completion_date IS NOT NULL
    OR (completion_date IS NULL AND (status <> 'failed')))

);
    -- n.b constraints to add a company cannot be acquired before it could be implemented with a similar method as below


-- ref: https://www.postgresql.org/docs/9.1/plpgsql-trigger.html--PLPGSQL-TRIGGER-EXAMPLE
CREATE FUNCTION acquisition_date_constraint() RETURNS trigger AS $acquisition_date_constraint$
    BEGIN
        IF NEW.announced_date < (SELECT founded FROM company WHERE id = NEW.child_company_id) THEN
            RAISE EXCEPTION '% cannot have null salary', NEW.announced_date;
        END IF;

        RETURN NEW;
    END;
$acquisition_date_constraint$ LANGUAGE plpgsql;

-- Run the trigger whenever a row is inserted or upated to acquisitions
CREATE TRIGGER acquisition_date_constraint BEFORE INSERT OR UPDATE ON acquistion
    FOR EACH ROW EXECUTE PROCEDURE acquisition_date_constraint();




