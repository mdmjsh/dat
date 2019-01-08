--PostgreSQL 9.6

CREATE TYPE ISO3166_ALPHA2 AS ENUM ('DE', 'FR', 'GB', 'US', 'JP', 'CN');


CREATE TYPE AQUISITION_STATUS AS ENUM ('announced', 'completed', 'failed');


DROP TABLE IF EXISTS country CASCADE;


CREATE TABLE country (name varchar (255) NOT NULL, code ISO3166_ALPHA2 NOT NULL, PRIMARY KEY (code));


DROP TABLE IF EXISTS company;


CREATE TABLE company (id serial, name varchar (255) NOT NULL, founded date NOT NULL, country_code ISO3166_ALPHA2 NOT NULL, parent_company_id int DEFAULT NULL, -- need to make this an int not a serial to allow nulls
 -- Constraints
 PRIMARY KEY (id), CONSTRAINT company_name_country UNIQUE (name, country_code),
                      FOREIGN KEY (country_code) REFERENCES country (code),
                      FOREIGN KEY (parent_company_id) REFERENCES company (id));


ALTER TABLE company ADD CONSTRAINT not_own_parent CHECK (id != parent_company_id);


CREATE TABLE founder (id serial, firstname varchar (255) NOT NULL, lastname varchar (255) NOT NULL, dob date NOT NULL, country_of_origin ISO3166_ALPHA2 NOT NULL, PRIMARY KEY (id),
                      FOREIGN KEY (country_of_origin) REFERENCES country (code));


CREATE TABLE founder_companies(founder_id serial, company_id serial,
                               FOREIGN KEY (founder_id) REFERENCES founder (id),
                               FOREIGN KEY (company_id) REFERENCES company (id));


CREATE TABLE acquisition (parent_company_id int NOT NULL, child_company_id int NOT NULL, status AQUISITION_STATUS NOT NULL, price_usd NUMERIC DEFAULT NULL, announced_date DATE NOT NULL, completion_date DATE DEFAULT NULL,
                          FOREIGN KEY (parent_company_id) REFERENCES company (id),
                          FOREIGN KEY (child_company_id) REFERENCES company (id));


ALTER TABLE acquisition ADD CONSTRAINT no_zero_acquisitions CHECK (price_usd > 0);

 -- An acquisition cannot complete before it is announced

ALTER TABLE acquisition ADD CONSTRAINT check_completion_date CHECK (completion_date >= announced_date);

 -- A company cannot acquire itself

ALTER TABLE acquisition ADD CONSTRAINT no_self_acquisitions CHECK (parent_company_id <> child_company_id);

 -- No completion date for failed acquisitions

ALTER TABLE acquisition ADD CONSTRAINT check_no_failed_completion_dates CHECK (status <> 'failed'
                                                                               OR status = 'failed'
                                                                               AND (completion_date IS NULL));


CREATE FUNCTION acquisition_date_constraint() RETURNS TRIGGER AS $acquisition_date_constraint$ BEGIN IF NEW.announced_date <
  (SELECT founded
   FROM company
   WHERE id = NEW.child_company_id) THEN RAISE EXCEPTION '% Acquisition cannot be announced before company founded!',
                                                         NEW.announced_date; END IF; RETURN NEW; END; $acquisition_date_constraint$ LANGUAGE plpgsql;

 -- Run the trigger whenever a row is inserted or upated to acquisitions

CREATE TRIGGER acquisition_date_constraint
BEFORE
INSERT
OR
UPDATE ON acquisition
FOR EACH ROW EXECUTE PROCEDURE acquisition_date_constraint();

