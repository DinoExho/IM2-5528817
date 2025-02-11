CREATE TABLE "account" (
  "account_id" serial,
  "customer_id" integer,
  "account_type" varchar,
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
  "interest_rate" percentage,
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

ALTER TABLE "account" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "transaction_records" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "loan_information" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "audit_trail" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("account_id");

ALTER TABLE "employees" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "user_roles" ("role_id");

