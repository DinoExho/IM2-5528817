CREATE ROLE customers;
CREATE ROLE bank_managers;
CREATE ROLE tellers;
CREATE ROLE loan_officers;

CREATE USER bank_manager1 WITH PASSWORD 'WLNHj3RdEQ5F' LOGIN;
GRANT bank_managers TO bank_manager1;

CREATE USER loan_officer1 WITH PASSWORD 'yLBZNz39TZTK' LOGIN;
GRANT loan_officers TO loan_officer1;

CREATE USER teller1 WITH PASSWORD 'AN8jv2uZvyaJ' LOGIN;
GRANT tellers TO teller1;

CREATE USER customer1 WITH PASSWORD 'GkbfZ7Z7TD8j' LOGIN;
GRANT customers TO customer1;


GRANT USAGE ON SCHEMA public TO bank_managers;
GRANT USAGE ON SCHEMA public TO loan_officers;
GRANT USAGE ON SCHEMA public TO tellers;
GRANT USAGE ON SCHEMA public TO customers;


CREATE TABLE "account" (
  "account_id" serial,
  "customer_id" integer,
  "account_type" varchar,
  "balance" money,
  "open_date" date,
  "account_status" varchar
);

CREATE TABLE "transaction_records" (
  "transaction_id" serial,
  "account_id" integer,
  "transaction_type" varchar,
  "transaction_timestamp" timestamp,
  "amount" money,
  "payment_method" varchar,
  "description" text
);

CREATE TABLE "employees" (
  "employee_id" serial,
  "forename" varchar,
  "surname" varchar,
  "email" varchar,
  "phone" varchar,
  "job_title" varchar,
  "user_id" integer
);

CREATE TABLE "loan_information" (
  "loan_id" serial,
  "account_id" integer,
  "original_amount" money,
  "interest_rate" decimal,
  "loan_term" varchar,
  "start_date" date,
  "end_date" date
);

CREATE TABLE "user_roles" (
  "role_id" serial,
  "role_name" varchar
);

CREATE TABLE "users" (
  "user_id" serial,
  "username" varchar,
  "password" varchar,
  "role_id" integer,
  "last_login" text
);

CREATE TABLE "customers" (
  "customer_id" serial,
  "forename" varchar,
  "surname" varchar,
  "dob" date,
  "email" varchar,
  "phone" varchar,
  "address" text,
  "user_id" integer
);

CREATE TABLE "audit_trail" (
  "audit_id" serial,
  "account_id" integer,
  "audit_timestamp" timestamp,
  "action_details" text,
  "affected_record" varchar,
  "old_data" text,
  "new_data" text
);

CREATE VIEW contact_employees WITH (security_barrier='false') AS
 SELECT
  e.forename,
  e.surname,
  e.email,
  e.phone
   FROM employees e;


CREATE VIEW financial_flow WITH (security_barrier='false') AS
 SELECT
  SUM(CASE WHEN t.transaction_type = 'IN' THEN amount ELSE 0 END) AS total_income,
  SUM(CASE WHEN t.transaction_type = 'OUT' THEN amount ELSE 0 END) AS total_outgoing,
  SUM(CASE WHEN t.transaction_type = 'incoming' THEN amount ELSE 0 END) - SUM(CASE WHEN transaction_type = 'outgoing' THEN amount ELSE 0 END) AS net_flow
FROM
    transaction_records t
WHERE
    t.transaction_date >= CURRENT_DATE - INTERVAL '7 days'

CREATE VIEW loans_due WITH (security_barrier='false') AS
 SELECT
  c.forename,
  c.surname,
  l.loan_id,
  l.account_id,
  l.original_amount,
  l.interest_rate,
  l.loan_term,
  l.start_date,
  l.end_date,
    FROM customers c, loan_information l
    WHERE end_date <= CURRENT_DATE;
	

CREATE VIEW customer_transactions WITH (security_barrier='false') AS
 SELECT
  c.forename,
  c.surname,
  t.type,
  t.date,
  t.amount,
  t.payment_method,
  t.description
    FROM customers c, transaction_records t
    WHERE (c.customer_id = account.customer_id) AND (account.account_id = t.account_id);
 	  

CREATE VIEW customer_incoming WITH (security_barrier='false') AS
 SELECT
  t.date,
  t.amount,
  t.payment_method,
  t.description
    FROM transaction_records t
    WHERE t.type = "incoming";

CREATE VIEW customer_outgoing WITH (security_barrier='false') AS
 SELECT
  t.date,
  t.amount,
  t.payment_method,
  t.description
    FROM transaction_records t
    WHERE t.type = "outgoing";

CREATE FUNCTION update_customer(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible ) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE customers SET %I = $1 WHERE customer_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;


CREATE FUNCTION update_employee(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible ) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE employees SET %I = $1 WHERE employee_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;


CREATE FUNCTION update_loans(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible ) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE loan_information SET %I = $1 WHERE loan_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;

-- INSERT FUNCTION TEMPLATE -----------------------------------------------------------
-- CREATE FUNCTION insertfuncname(values types) RETURNS void
-- LANGUAGE plpgsql
-- AS 
-- $$
-- BEGIN
-- 	INSERT INTO tablename (values)
-- 	VALUES (values);
-- END 
-- $$;
---------------------------------------------------------------------------------------


-- UPDATE FUNCTION TEMPLATE -----------------------------------------------------------
-- CREATE FUNCTION updatefuncname(values types) RETURNS void
-- 	LANGUAGE plpgsql
-- 	AS $$DECLARE
-- 	sql_query TEXT;
-- BEGIN    
-- sql_query := format('UPDATE tablename SET %I = $1 WHERE IDENTIFIER = $2', p_fieldname);
-- EXECUTE sql_query USING p_newvalue, p_identifier;
-- END;
-- $$;
--------------------------------------------------------------------------------------

ALTER TABLE "account" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "transaction_records" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "loan_information" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "audit_trail" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "employees" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "user_roles" ("role_id");

