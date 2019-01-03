--PostgreSQL 9.6

CREATE TYPE ISO3166_ALPHA2 AS ENUM (
    'DE',
    'FR',
    'GB',
    'US',
    'JP',
    'CN'
);

CREATE TYPE AQUISITION_STATUS AS ENUM (
    'announced'
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
    failed_date DATE default null,
    FOREIGN KEY (parent_company_id) REFERENCES company (id),
    FOREIGN KEY (child_company_id) REFERENCES company (id),
    CONSTRAINT no_zero_acquisitions CHECK (price_usd > 0)

    ,

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


