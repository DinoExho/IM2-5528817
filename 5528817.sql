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
GRANT USAGE ON SCHEMA public TO s;

-------------------- TABLES --------------------
CREATE TABLE "account" (
  "account_id" serial NOT NULL,
  "_id" integer NOT NULL,
  "account_type" varchar NOT NULL,
  "balance" money NOT NULL,
  "open_date" date NOT NULL,
  "account_status" varchar NOT NULL
);

REVOKE ALL ON TABLE account FROM PUBLIC;
GRANT ALL ON TABLE account to bank_managers;
GRANT SELECT ON TABLE account to loan_officers;
GRANT SELECT ON TABLE account to tellers;
GRANT SELECT,UPDATE ON TABLE account to s;


CREATE TABLE "transaction_records" (
  "transaction_id" serial NOT NULL,
  "account_id" integer NOT NULL,
  "transaction_type" varchar NOT NULL,
  "transaction_timestamp" timestamp NOT NULL,
  "amount" money NOT NULL,
  "payment_method" varchar NOT NULL,
  "description" text NOT NULL
);

REVOKE ALL ON TABLE transactions_records FROM PUBLIC;
GRANT SELECT ON TABLE transactions_records to bank_managers;
GRANT SELECT ON TABLE transactions_records to loan_officers;
GRANT SELECT ON TABLE transactions_records to tellers;
GRANT SELECT ON TABLE transactions_records to s;

CREATE TABLE "employees" (
  "employee_id" serial NOT NULL,
  "forename" varchar NOT NULL,
  "surname" varchar NOT NULL,
  "email" varchar NOT NULL,
  "phone" varchar NOT NULL,
  "job_title" varchar NOT NULL,
  "user_id" integer NOT NULL
);

REVOKE ALL ON TABLE employees FROM PUBLIC;
GRANT ALL ON TABLE employees to bank_managers;
GRANT SELECT,UPDATE ON TABLE employees to loan_officers;
GRANT SELECT,UPDATE ON TABLE employees to tellers;

CREATE TABLE "loan_information" (
  "loan_id" serial NOT NULL,
  "account_id" integer NOT NULL,
  "original_amount" money NOT NULL,
  "interest_rate" decimal NOT NULL,
  "loan_term" varchar NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL
);

REVOKE ALL ON TABLE loan_information FROM PUBLIC;
GRANT ALL ON TABLE loan_information to bank_managers;
GRANT ALL ON TABLE loan_information to loan_officers;
GRANT SELECT ON TABLE loan_information to tellers;
GRANT SELECT ON TABLE loan_information to s;

CREATE TABLE "user_roles" (
  "role_id" serial NOT NULL,
  "role_name" varchar NOT NULL
);

REVOKE ALL ON TABLE user_roles FROM PUBLIC;
GRANT ALL ON TABLE user_roles to bank_managers;


CREATE TABLE "users" (
  "user_id" serial NOT NULL,
  "username" varchar NOT NULL,
  "password" varchar NOT NULL,
  "role_id" integer NOT NULL,
  "last_login" text NOT NULL
);

REVOKE ALL ON TABLE users FROM PUBLIC;
GRANT ALL ON TABLE users to bank_managers;
GRANT SELECT,UPDATE ON TABLE users to loan_officers;
GRANT SELECT,UPDATE ON TABLE users tellers;
GRANT SELECT,UPDATE ON TABLE users to customers;


CREATE TABLE "customers" (
  "customer_id" serial NOT NULL,
  "forename" varchar NOT NULL,
  "surname" varchar NOT NULL,
  "dob" date NOT NULL,
  "email" varchar NOT NULL,
  "phone" varchar NOT NULL,
  "address" text NOT NULL,
  "user_id" integer NOT NULL
);

REVOKE ALL ON TABLE customers FROM PUBLIC;
GRANT ALL ON TABLE customers to bank_managers;
GRANT SELECT,UPDATE ON TABLE customers to loan_officers;
GRANT SELECT,UPDATE ON TABLE customers to tellers;
GRANT SELECT,UPDATE ON TABLE customers to customers;

CREATE TABLE "audit_trail" (
  "audit_id" serial NOT NULL,
  "account_id" integer NOT NULL,
  "audit_timestamp" timestamp NOT NULL,
  "action_details" text NOT NULL,
  "affected_record" varchar NOT NULL,
  "old_data" text NOT NULL,
  "new_data" text NOT NULL
);

REVOKE ALL ON TABLE audit_trail FROM PUBLIC;
GRANT SELECT ON TABLE audit_trail to bank_managers;

-----------------------------------------------


-------------------- POLICIES --------------------
CREATE POLICY user_data_policy ON orders
USING (user_id = current_user); 



-------------------- VIEWS --------------------

CREATE VIEW BankManager_Account AS
SELECT account_id, account_type, balance, open_date, account_status
FROM account;

CREATE VIEW Customer_Account AS
SELECT account_id, account_type, balance, open_date, account_status
FROM account;


CREATE VIEW BankManager_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address, user_id
FROM customer;

CREATE VIEW LoanOfficer_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address, user_id
FROM customer;

CREATE VIEW Customer_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address, user_id
FROM customer;


CREATE VIEW BankManager_Transaction AS
SELECT transaction_id, account_id, transaction_type, transaction_timestamp, amount, payment_method, description
FROM transaction;

CREATE VIEW Teller_Transaction AS
SELECT transaction_id, account_id, transaction_type, transaction_timestamp, amount, payment_method, description
FROM transaction;


CREATE VIEW BankManager_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;

CREATE VIEW LoanOfficer_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;

CREATE VIEW Customer_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;


CREATE VIEW BankManager_Employee AS
SELECT employee_id, forename, surname, email, phone, job_title, user_id
FROM employee;

CREATE VIEW Teller_Employee AS
SELECT employee_id, forename, surname, email, phone, job_title, user_id
FROM employee;


CREATE VIEW BankManager_AuditTrail AS
SELECT audit_id, account_id, audit_timestamp, action_details, affected_record, old_data, new_data
FROM audit_trail;

CREATE VIEW BankManager_UserRoles AS
SELECT role_id, role_name
FROM user_roles;


CREATE VIEW BankManager_Users AS
SELECT user_id, username, role_id, last_login  -- Exclude password for security
FROM users;

CREATE VIEW LoanOfficer_Users AS
SELECT user_id, username, role_id, last_login  -- Exclude password for security
FROM users;



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
---------------------------------------------------

-------------------- FUNCTIONS --------------------

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
RETURNS TABLE (audit_id integer, account_id integer, audit_timestamp TIMESTAMP WITH TIME ZONE, action_details text, affected_record varchar, old_data text, new_data text)
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


CREATE OR REPLACE FUNCTION update_customer(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE customers SET %I = $1 WHERE customer_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;


CREATE OR REPLACE FUNCTION update_employee(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE employees SET %I = $1 WHERE employee_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;


CREATE OR REPLACE FUNCTION update_loans(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	sql_query TEXT;
BEGIN    
	sql_query := format('UPDATE loan_information SET %I = $1 WHERE loan_id = $2', p_fieldname);
	EXECUTE sql_query USING p_newvalue, p_identifier;
END;
$$;

CREATE OR REPLACE FUNCTION remove_employee(employee_id integer) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM employees WHERE id = employee_id) THEN
        DELETE FROM employees WHERE id = employee_id_to_remove;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION insert_loan(p_account_id integer, p_original_amount money, p_interest_rate decimal,  p_loan_term varchar, p_start_date date, p_end_date date) RETURNS void
LANGUAGE plpgsql
AS 
$$
BEGIN
	INSERT INTO loan_information (account_id, original_amount, interest_rate,  loan_term, start_date, end_date)
	VALUES (p_account_id, p_original_amount, p_interest_rate,  p_loan_term, p_start_date, p_end_date);
END 
$$;

CREATE OR REPLACE FUNCTION transfer_funds(sender_account_id integer, receiver_account_id integer, amount NUMERIC, description text)
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

CREATE OR REPLACE FUNCTION insert_customer(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_dob date, p_email varchar, p_phone varchar, p_address text)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        INSERT INTO users (username, password, role_id, last_login)
        VALUES (p_username, p_password, 4, NOW());  

        INSERT INTO customers (forename, surname, dob, email, phone, address, user_id)
        VALUES (p_forename, p_surname, p_dob, p_email, p_phone, p_address, LASTVAL());


	EXECUTE format('CREATE ROLE %I WITH PASSWORD %L LOGIN', username, password);
	EXECUTE format('GRANT customers TO %I;', username);
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION insert_employee(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_email varchar, p_phone varchar, p_job_title varchar, p_role_id integer) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	group_role varchar;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
	INSERT INTO users (username, password, role_id, last_login)
        VALUES (p_username, p_password, p_role_id, NOW());  

	INSERT INTO employees(forename, surname, email, phone, job_title, user_id)
	VALUES (p_forename, p_surname, p_email, p_phone, p_job_title, p_user_id);

	SELECT role_name INTO group_role FROM user_roles WHERE role_id = p_role_id)
	EXECUTE format('CREATE ROLE %I WITH PASSWORD %L LOGIN', username, password);
	EXECUTE format('GRANT %I TO %L;', group_role, username);
END IF;
END;
$$;


-------------------- VIEWS SECURITY --------------------
REVOKE ALL ON VIEW customerinfo_customers FROM PUBLIC;
GRANT ALL ON VIEW customerinfo_customers to customers;

REVOKE ALL ON VIEW financial_flow FROM PUBLIC;
GRANT ALL ON VIEW financial_flow to bank_managers;

REVOKE ALL ON VIEW loans_due FROM PUBLIC;
GRANT ALL ON VIEW loans_due to loan_officers;

REVOKE ALL ON VIEW customer_transactions FROM PUBLIC;
GRANT ALL ON VIEW customer_transactions to tellers;

REVOKE ALL ON VIEW customer_incoming FROM PUBLIC;
GRANT ALL ON VIEW customer_incoming to customers;

REVOKE ALL ON VIEW customer_outgoing FROM PUBLIC;
GRANT ALL ON VIEW customer_outgoing to customers;
------------------------------------------------------------


-------------------- FUNCTIONS SECURITY --------------------
REVOKE ALL ON FUNCTION customer_active_loans(user_id integer) FROM PUBLIC;
GRANT SELECT ON FUNCTION customer_active_loans(user_id integer) to customers;

REVOKE ALL ON FUNCTION customer_active_loans_loanofficer(user_id integer) FROM PUBLIC;
GRANT SELECT ON FUNCTION customer_active_loans_loanofficer(user_id integer) to loan_officers;

REVOKE ALL ON FUNCTION customer_accounts(customer_id integer) FROM PUBLIC; 
GRANT SELECT ON FUNCTION customer_accounts(customer_id integer) to customers;

REVOKE ALL ON FUNCTION account_audit_trail(account_id_ INT) FROM PUBLIC; 
GRANT SELECT ON FUNCTION account_audit_trail(account_id_ INT) to bank_managers;

REVOKE ALL ON FUNCTION update_customer(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) FROM PUBLIC; 
GRANT SELECT ON FUNCTION update_customer(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) to customers;

REVOKE ALL ON FUNCTION insert_employee(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_email varchar, p_phone varchar, p_job_title varchar, p_role_id integer) FROM PUBLIC; 
GRANT SELECT ON FUNCTION insert_employee(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_email varchar, p_phone varchar, p_job_title varchar, p_role_id integer) to bank_managers;

REVOKE ALL ON FUNCTION update_employee(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) FROM PUBLIC; 
GRANT SELECT ON FUNCTION update_employee(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) to bank_managers;

REVOKE ALL ON FUNCTION update_loans(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) FROM PUBLIC; 
GRANT SELECT ON FUNCTION update_loans(p_identifier integer, p_fieldname character varying, p_newvalue anycompatible) to loan_officers;

REVOKE ALL ON FUNCTION remove_employee(employee_id integer) FROM PUBLIC; 
GRANT SELECT ON FUNCTION remove_employee(employee_id integer) to bank_managers;

REVOKE ALL ON FUNCTION insert_loan(p_account_id integer, p_original_amount money, p_interest_rate decimal,  p_loan_term varchar, p_start_date date, p_end_date date) FROM PUBLIC; 
GRANT SELECT ON FUNCTION insert_loan(p_account_id integer, p_original_amount money, p_interest_rate decimal,  p_loan_term varchar, p_start_date date, p_end_date date) to loan_officers;

REVOKE ALL ON FUNCTION transfer_funds(sender_account_id integer, receiver_account_id integer, amount NUMERIC, description text) FROM PUBLIC; 
GRANT SELECT ON FUNCTION transfer_funds(sender_account_id integer, receiver_account_id integer, amount NUMERIC, description text) to customers;

REVOKE ALL ON FUNCTION insert_customer(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_dob date, p_email varchar, p_phone varchar, p_address text) FROM PUBLIC; 
GRANT SELECT ON FUNCTION insert_customer(p_username varchar, p_password varchar, p_forename varchar, p_surname varchar, p_dob date, p_email varchar, p_phone varchar, p_address text) to bank_managers;

------------------------------------------------------

-------------------- AUDIT LOGGER --------------------

CREATE OR REPLACE FUNCTION audit_logger()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO audit_trail (account_id, audit_timestamp, action_details, affected_record, old_data, new_data)
  VALUES (TG_TABLE_NAME.account_id, now(),
    CASE TG_OP
      WHEN 'INSERT' THEN 'INSERTED'
      WHEN 'UPDATE' THEN 'UPDATED'
      WHEN 'DELETE' THEN 'DELETED'
    END, TG_TABLE_NAME || '.' || TG_TABLE_NAME.audit_id::text);
   RETURN NULL; 
END;
$$;

CREATE TRIGGER account_trigger
AFTER INSERT OR UPDATE OR DELETE ON account 
FOR EACH ROW
EXECUTE PROCEDURE audit_logger();

CREATE TRIGGER loan_information_trigger
AFTER INSERT OR UPDATE OR DELETE ON loan_information 
FOR EACH ROW
EXECUTE PROCEDURE audit_logger();

CREATE TRIGGER transaciton_records_trigger
AFTER INSERT OR UPDATE OR DELETE ON transaciton_records 
FOR EACH ROW
EXECUTE PROCEDURE audit_logger();

------------------------------------------------------------


-------------------- TABLE FOREIGN KEYS --------------------

ALTER TABLE "account" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "transaction_records" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "loan_information" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "audit_trail" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "employees" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "user_roles" ("role_id");

