--PostgreSQL 9.6

CREATE TYPE ISO3166_ALPHA2 AS ENUM ( 'DE', 'FR', 'GB', 'SS', 'US');


CREATE TYPE AQUISITION_STATUS AS ENUM ( 'announced' 'completed', 'failed');


DROP TABLE IF EXISTS company;


CREATE TABLE company ( id serial, name varchar (255) NOT NULL, founded date NOT NULL, country_code char (2) NOT NULL, parent_company_id serial, -- Constraints
 CONSTRAINT company_name_country UNIQUE (name, country_code), PRIMARY KEY (id),
                      FOREIGN KEY (country_code) REFERENCES country (code), CONSTRAINT not_own_parent CHECK (id != parent_company_id));


DROP TABLE IF EXISTS country CASCADE;


CREATE TABLE country ( name varchar (255) NOT NULL, code ISO3166_ALPHA2 NOT NULL, PRIMARY KEY (code));


CREATE TABLE founder ( id serial, name varchar (255) NOT NULL, dob date NOT NULL, country_of_origin ISO3166_ALPHA2 NOT NULL, PRIMARY KEY (id),
                      FOREIGN KEY (country_of_origin) REFERENCES country (code));


CREATE TABLE acquistion ( parent_company_id serial NOT NULL, child_company_id serial NOT NULL, -- An acquisition has to be announced for it to be in this table
 -- hence default value
 status AQUISITION_STATUS, price_usd NUMERIC DEFAULT NULL, announced_date DATE NOT NULL, completion_date DATE DEFAULT NULL,
                         FOREIGN KEY (parent_company_id) REFERENCES company (id),
                         FOREIGN KEY (child_company_id) REFERENCES company (id), CONSTRAINT no_zero_acquisitions CHECK (price_usd > 0), -- If an acquisition is failed it must not have a completion date
 CONSTRAINT check_completion_date CHECK (completion_date >= announced_date), -- A company cannot acquire itself
 CONSTRAINT no_self_acquisitions CHECK (parent_company_id <> child_company_id), -- No completion date for failed acquisitions
 CONSTRAINT check_no_failed_completion_dates CHECK ( completion_date IS NOT NULL
                                                    OR (completion_date IS NULL
                                                        AND (status <> 'failed'))) );


CREATE FUNCTION acquisition_date_constraint() RETURNS TRIGGER AS $acquisition_date_constraint$ BEGIN IF NEW.announced_date <
  (SELECT founded
   FROM company
   WHERE id = NEW.child_company_id) THEN RAISE EXCEPTION '% cannot have null salary',
                                                         NEW.announced_date; END IF; RETURN NEW; END; $acquisition_date_constraint$ LANGUAGE plpgsql;

 -- Run the trigger whenever a row is inserted or upated to acquisitions

CREATE TRIGGER acquisition_date_constraint
BEFORE
INSERT
OR
UPDATE ON acquistion
FOR EACH ROW EXECUTE PROCEDURE acquisition_date_constraint();

