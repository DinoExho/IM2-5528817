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

CREATE VIEW customerinfo_loanofficers AS
SELECT
    customer_id,
    forename,
    surname
FROM
    customers;

CREATE VIEW customerinfo_tellers AS
SELECT
    forename,
    surname,
    dob,
FROM
    customers;


CREATE VIEW customerinfo_customers AS
SELECT
    forename,
    surname,
    dob,
    phone,
    email,
    address,
FROM
    customers;


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
	
CREATE OR REPLACE FUNCTION customer_active_loans(user_id integer)
RETURNS TABLE (account_id integer, original_amount numeric, interest_rate decimal, loan_term varchar, end_date date)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        account_id, original_amount, interest_rate, loan_term, end_date
    FROM
        loan_information
    WHERE
        customer_id = user_id AND loan_start_date <= CURRENT_DATE AND loan_end_date >= CURRENT_DATE;
END;
$$;

CREATE OR REPLACE FUNCTION customer_active_loans_loanofficer(user_id integer)
RETURNS TABLE (loan_id integer, account_id integer, original_amount numeric, interest_rate decimal, loan_term varchar, start_date date, end_date date)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
    FROM
        loan_information
    WHERE
        customer_id = user_id AND loan_start_date <= CURRENT_DATE AND loan_end_date >= CURRENT_DATE;
END;
$$;


CREATE OR REPLACE FUNCTION customer_accounts(customer_id integer)
LANGUAGE plpgsql
RETURNS TABLE (account_id, customer_id, open_date)
AS $$
BEGIN
    RETURN QUERY
    SELECT
       a.balance
    FROM
        accounts a  
    JOIN
        customers c ON a.customer_id = c.customer_id
    WHERE
        c.customer_id = customer_id;
END;
$$;

CREATE OR REPLACE FUNCTION account_audit_trail(account_id_ INT)
RETURNS TABLE (audit_id INT, account_id INT, audit_timestamp TIMESTAMP WITH TIME ZONE, action_details text, affected_record varchar, old_data text, new_data text)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        audit_id,
	account_id, 
	audit_timestamp, 
	action_details, 
	affected_record,
	old_data, 
	new_data
    FROM
        audit_trail a
    WHERE
        a.account_id = account_id;
END;
$$;


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


CREATE FUNCTION insert_employee( p_forename varchar, p_surname varchar, p_email varchar, p_phone varchar, p_job_title varchar, p_user_id integer) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO employees(forename, surname, email, phone, job_title, user_id)
	VALUES (p_forename, p_surname, p_email, p_phone, p_job_title, p_user_id);
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

CREATE FUNCTION remove_employee(employee_id integer) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM employees WHERE id = employee_id) THEN
        DELETE FROM employees WHERE id = employee_id_to_remove;
    END IF;
END;
$$;

CREATE FUNCTION insert_loan(p_account_id integer, p_original_amount money, p_interest_rate decimal,  p_loan_term varchar, p_start_date date, p_end_date date) RETURNS void
LANGUAGE plpgsql
AS 
$$
BEGIN
	INSERT INTO loan_information (account_id, original_amount, interest_rate,  loan_term, start_date, end_date)
	VALUES (p_account_id, p_original_amount, p_interest_rate,  p_loan_term, p_start_date, p_end_date);
END 
$$;

CREATE OR REPLACE FUNCTION transfer_funds(sender_account_id INT, receiver_account_id INT, amount NUMERIC, description text)
RETURNS BOOLEAN 
LANGUAGE plpgsql
AS $$
DECLARE
    sender_balance NUMERIC;
    receiver_balance NUMERIC;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = sender_account_id OR account_id = receiver_account_id) THEN
        RETURN FALSE;
    END IF;

    IF amount <= 0 THEN
        RETURN FALSE;
    END IF;

    SELECT balance INTO sender_balance FROM accounts WHERE account_id = sender_account_id FOR UPDATE;

    IF sender_balance < amount THEN
        RETURN FALSE;
    END IF;

	UPDATE accounts SET balance = balance - amount WHERE account_id = sender_account_id;
	UPDATE accounts SET balance = balance + amount WHERE account_id = receiver_account_id;

	INSERT INTO transaction_records (account_id, transaction_type, transaction_timestamp, amount, payment_method, description)
	VALUES (sender_account_id, 'outgoing', NOW(), amount, 'Bank Transfer', description); 
	
	INSERT INTO transaction_records (account_id, transaction_type, transaction_timestamp, amount, payment_method, description)
	VALUES (receiver_account_id, 'incoming', NOW(), amount, 'Bank Transfer', description); 

        RETURN TRUE;
END;
$$;


ALTER TABLE "account" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "transaction_records" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "loan_information" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "audit_trail" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "employees" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "user_roles" ("role_id");

