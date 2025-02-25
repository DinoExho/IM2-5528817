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

-------------------- TABLES --------------------
CREATE TABLE "account" (
  "account_id" serial NOT NULL,
  "customer_id" integer NOT NULL,
  "account_type" varchar NOT NULL,
  "balance" money NOT NULL,
  "open_date" date NOT NULL,
  "account_status" varchar NOT NULL
);

REVOKE ALL ON TABLE account FROM PUBLIC;
GRANT ALL ON TABLE account to bank_managers;
GRANT SELECT ON TABLE account to loan_officers;
GRANT SELECT ON TABLE account to tellers;
GRANT SELECT ON TABLE account to customers;


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
GRANT SELECT ON TABLE transactions_records to customers;

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
GRANT SELECT ON TABLE employees to loan_officers;
GRANT SELECT ON TABLE employees to tellers;

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
GRANT SELECT ON TABLE loan_information to customers;

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
GRANT SELECT ON TABLE users to loan_officers;
GRANT SELECT ON TABLE users tellers;
GRANT SELECT ON TABLE users to customers;


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
GRANT SELECT ON TABLE customers to loan_officers;
GRANT SELECT ON TABLE customers to tellers;
GRANT SELECT ON TABLE customers to customers;

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

CREATE POLICY account_customer_policy ON account USING (EXISTS (SELECT 1 FROM users u JOIN customer c ON u.user_id = c.user_id WHERE u.username = current_user AND c.customer_id = account.customer_id));
ALTER TABLE account ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_customer_policy ON customer USING (EXISTS (SELECT 1 FROM users u WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'customers') AND u.user_id = customer.user_id));
ALTER TABLE customer ENABLE ROW LEVEL SECURITY;

CREATE POLICY transaction_customer_policy ON transaction USING (EXISTS (SELECT 1 FROM users u JOIN customer c ON u.user_id = c.user_id JOIN account a ON c.customer_id = a.customer_id WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'customers') AND a.account_id = transaction.account_id));
ALTER TABLE transaction ENABLE ROW LEVEL SECURITY;

CREATE POLICY loan_customer_policy ON loan USING (EXISTS (SELECT 1 FROM users u JOIN customer c ON u.user_id = c.user_id JOIN account a ON c.customer_id = a.customer_id WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'customers') AND a.account_id = loan.account_id));
ALTER TABLE loan ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_bank_manager_policy ON employee USING (EXISTS (SELECT 1 FROM users u WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'bank_managers')));
CREATE POLICY employee_loan_officer_policy ON employee USING (EXISTS (SELECT 1 FROM users u WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'loan_officers')));
CREATE POLICY employee_teller_policy ON employee USING (EXISTS (SELECT 1 FROM users u WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'tellers')));
ALTER TABLE employee ENABLE ROW LEVEL SECURITY;

CREATE POLICY audit_trail_bank_manager_policy ON audit_trail USING (EXISTS (SELECT 1 FROM users u WHERE u.username = current_user AND u.role_id = (SELECT role_id FROM user_roles WHERE role_name = 'bank_managers')));
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

-------------------- VIEWS --------------------

CREATE OR REPLACE VIEW BankManager_Account AS
SELECT account_id, customer_id, account_type, balance, open_date, account_status
FROM account;

CREATE OR REPLACE VIEW LoanOfficer_Account AS
SELECT account_id, customer_id, account_type, balance, open_date, account_status
FROM account;

CREATE OR REPLACE VIEW Customer_Account AS
SELECT account_id, account_type, balance, open_date, account_status
FROM account;


CREATE OR REPLACE VIEW BankManager_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address
FROM customer;

CREATE OR REPLACE VIEW LoanOfficer_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address
FROM customer;

CREATE OR REPLACE VIEW Customer_Customer AS
SELECT customer_id, forename, surname, dob, email, phone, address
FROM customer;


CREATE OR REPLACE VIEW BankManager_Transaction AS
SELECT transaction_id, account_id, transaction_type, transaction_timestamp, amount, payment_method, description
FROM transaction;

CREATE OR REPLACE VIEW LoanOfficer_Transaction AS
SELECT transaction_id, account_id, transaction_type, transaction_timestamp, amount, payment_method, description
FROM transaction;

CREATE OR REPLACE VIEW Teller_Transaction AS
SELECT transaction_id, account_id, transaction_type, transaction_timestamp, amount, payment_method, description
FROM transaction;


CREATE OR REPLACE VIEW BankManager_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;

CREATE OR REPLACE VIEW LoanOfficer_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;

CREATE OR REPLACE VIEW Customer_Loan AS
SELECT loan_id, account_id, original_amount, interest_rate, loan_term, start_date, end_date
FROM loan;


CREATE OR REPLACE VIEW BankManager_Employee AS
SELECT employee_id, forename, surname, email, phone, job_title, user_id
FROM employee;

CREATE OR REPLACE VIEW LoanOfficer_Employee AS
SELECT employee_id, forename, surname, email, phone, job_title, user_id
FROM employee;

CREATE OR REPLACE VIEW Teller_Employee AS
SELECT employee_id, forename, surname, email, phone, job_title, user_id
FROM employee;


CREATE OR REPLACE VIEW BankManager_AuditTrail AS
SELECT audit_id, account_id, audit_timestamp, action_details, affected_record, old_data, new_data
FROM audit_trail;

CREATE OR REPLACE VIEW LoanOfficer_AuditTrail AS
SELECT audit_id, account_id, audit_timestamp, action_details, affected_record, old_data, new_data
FROM audit_trail;


CREATE OR REPLACE VIEW BankManager_UserRoles AS
SELECT role_id, role_name
FROM user_roles;


CREATE OR REPLACE VIEW BankManager_Users AS
SELECT user_id, username, role_id, last_login
FROM users;

CREATE OR REPLACE VIEW LoanOfficer_Users AS
SELECT user_id, username, role_id, last_login
FROM users;

---------------------------------------------------

-------------------- VIEWS SECURITY --------------------


GRANT SELECT ON BankManager_Account TO bank_managers;
GRANT SELECT ON LoanOfficer_Account TO loan_officers;
GRANT SELECT ON Customer_Account TO customers;

GRANT SELECT ON BankManager_Customer TO bank_managers;
GRANT SELECT ON LoanOfficer_Customer TO loan_officers;
GRANT SELECT ON Customer_Customer TO customers;

GRANT SELECT ON BankManager_Transaction TO bank_managers;
GRANT SELECT ON LoanOfficer_Transaction TO loan_officers;
GRANT SELECT ON Teller_Transaction TO tellers;

GRANT SELECT ON BankManager_Loan TO bank_managers;
GRANT SELECT ON LoanOfficer_Loan TO loan_officers;
GRANT SELECT ON Customer_Loan TO customers;

GRANT SELECT ON BankManager_Employee TO bank_managers;
GRANT SELECT ON LoanOfficer_Employee TO loan_officers;
GRANT SELECT ON Teller_Employee TO tellers;

GRANT SELECT ON BankManager_AuditTrail TO bank_managers;
GRANT SELECT ON LoanOfficer_AuditTrail TO loan_officers;

GRANT SELECT ON BankManager_UserRoles TO bank_managers;

GRANT SELECT ON BankManager_Users TO bank_managers;
GRANT SELECT ON LoanOfficer_Users TO loan_officers;


--------------------------------------------------------

-------------------- FUNCTIONS --------------------

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


CREATE OR REPLACE FUNCTION withdraw(p_account_id INT, p_amount NUMERIC)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM account WHERE account_id = p_account_id) THEN
    RETURN FALSE;
  END IF;

  IF balance < p_amount THEN
    RETURN FALSE;
  END IF;

  UPDATE account SET balance = balance - p_amount WHERE account_id = p_account_id;

  INSERT INTO transaction (account_id, transaction_type, amount, payment_method, description)
  VALUES (p_account_id, 'Withdrawal', p_amount, 'Transfer', 'Withdrawal'); 

  INSERT INTO audit_trail (account_id, audit_timestamp, action_details, affected_record, old_data, new_data)
  VALUES (p_account_id, NOW(), 'Withdrawal', 'account', balance + p_amount, balance);

  RETURN TRUE;
END;
$$;


CREATE OR REPLACE FUNCTION deposit(p_account_id INT, p_amount NUMERIC)
RETURNS BOOLEAN 
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM account WHERE account_id = p_account_id) THEN
    RETURN FALSE;
  END IF;

  UPDATE account SET balance = balance + p_amount WHERE account_id = p_account_id;

  INSERT INTO transaction (account_id, transaction_type, amount, payment_method, description)
  VALUES (p_account_id, 'Deposit', p_amount, 'Transfer', 'Deposit');

  INSERT INTO audit_trail (account_id, audit_timestamp, action_details, affected_record, old_data, new_data)
  VALUES (p_account_id, NOW(), 'Deposit', 'account', balance - p_amount, balance);

  RETURN TRUE;
END;
$$;

-------------------- FUNCTIONS SECURITY --------------------

REVOKE ALL ON FUNCTION account_audit_trail(account_id_ INT) FROM PUBLIC; 
GRANT SELECT ON FUNCTION account_audit_trail(account_id_ INT) to bank_managers;

REVOKE ALL ON FUNCTION withdraw(p_account_id INT, p_amount NUMERIC) FROM PUBLIC; 
GRANT SELECT ON FUNCTION withdraw(p_account_id INT, p_amount NUMERIC) to customers;

REVOKE ALL ON FUNCTION deposit(p_account_id INT, p_amount NUMERIC) FROM PUBLIC; 
GRANT SELECT ON FUNCTION deposit(p_account_id INT, p_amount NUMERIC) to customers;
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
AFTER INSERT OR UPDATE OR DELETE ON transaction_records 
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

