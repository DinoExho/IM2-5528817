echo '----------------- Test Script -----------------'
cp server.crt /var/lib/postgresql/
cp server.key /var/lib/postgresql/
chown postgres:postgres /var/lib/postgresql/server.*
echo ‘’
echo '----------------- Create Database -----------------'
dropdb --if-exists 5528817
createdb 5528817
psql 5528817 < 5528817.sql
echo ‘’
echo '----------------- Users, Views and Functions -----------------'
psql -d 5528817 -c "\du"
psql -d 5528817 -c "\dv"
psql -d 5528817 -c "\dt"
echo ''
echo ''
echo '----------------- Test Data as postgres -----------------'
echo ''
echo ''
echo '1 - create user roles - expected outcome: success'
PGPASSWORD=postgres psql -U postgres -d 5528817 -c "INSERT INTO user_roles(role_name) VALUES ('bank_manager'),('loan_officer'),('teller'),('customer');"
echo ''
echo '2 - create bank manager - expected outcome: success'
PGPASSWORD=postgres psql -U postgres -d 5528817 -c "INSERT INTO users (username, password, role_id, last_login) VALUES ('bjones', 'S3curePword!', 2, '2023-10-26 11:30:00');"
echo ''
echo '3 - create bank manager - expected outcome: success'
PGPASSWORD=postgres psql -U postgres -d 5528817 -c "INSERT INTO employees (forename, surname, email, phone, job_title, user_id) VALUES ('Benjamin', 'Jones', 'benjamin.jones@example.com', '07800 123456', 'bank_manager', 1);"
echo ''
echo ''
echo '----------------- Test Data as bank manager -----------------'
echo ''
echo ''
echo '4 - create loan officer - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO users (username, password, role_id, last_login) VALUES ('jdoe', 'yLBZNz39TZTK', 2, '2025-02-14 21:14:00'); INSERT INTO employees (forename, surname, email, phone, job_title, user_id) VALUES ('John', 'Doe', 'John.doe@example.com', '07700 123456', 'loan officer', 2);"
echo ''
echo '5 - create loan officer - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO employees (forename, surname, email, phone, job_title, user_id) VALUES ('John', 'Doe', 'John.doe@example.com', '07700 123456', 'loan officer', 2);"
echo ''
echo '6 - create teller - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO users (username, password, role_id, last_login) VALUES ('cjohnson', 'AN8jv2uZvyaJ', 3, '2025-01-02 18:43:00');"
echo ''
echo '7 - create teller - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO employees (forename, surname, email, phone, job_title, user_id) VALUES ('Carol', 'Johnson', 'carol.johnson@example.com', '07500 456789', 'teller', 3);"
echo ''
echo '8 - create customer - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO users (username, password, role_id, last_login) VALUES ('pbrown', 'complexpw', 4, '2024-12-27 9:51:00'); INSERT INTO customers (forename, surname, dob, email, phone, address, user_id) VALUES ('Patricia', 'Brown', '1978-03-18', 'patricia.brown@example.com', '07956 789012', '789 Oak Lane, Anytown', 4);"
echo ''
echo '9 - create customer - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO customers (forename, surname, dob, email, phone, address, user_id) VALUES ('Patricia', 'Brown', '1978-03-18', 'patricia.brown@example.com', '07956 789012', '789 Oak Lane, Anytown', 4);"
echo ''
echo '10 - view account audit trail - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "account_audit_trail"(1);"
echo ''
echo '11 - check customer table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Customer"(1);"
echo ''
echo '12 - check account table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Account"(1);"
echo ''
echo '13 - check audit_trail table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Transaction"(1);"
echo ''
echo '14 - check cannot insert/update/delete audit trail - expected outcome: fail'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '15 - check transactions_record table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_AuditTrail"(1);"
echo ''
echo '16 - check employees table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Employee"(1);"
echo ''
echo '17 - check users table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Users"(1);"
echo ''
echo '18 - check user_roles table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_UserRoles"(1);"
echo ''
echo '19 - check loan_information table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "BankManager_Loan"(1);"
echo ''
echo ''
echo '----------------- Test Data as loan officer -----------------'
echo ''
echo ''
echo '20 - check customer table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT "LoanOfficer_Customer"(1);"
echo ''
echo '21 - check account table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT "LoanOfficer_Account"(1);"
echo ''
echo '22 - check cannot access audit_Trail - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '23 - check transactions_record table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT "LoanOfficer_Transaction"(1);"
echo ''
echo '24 - check employees table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT "LoanOfficer_Employee"(1);"
echo ''
echo '25 - check cannot access users - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '26 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '27 - check loan_information table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT "LoanOfficer_Loan"(1);"
echo ''
echo ''
echo '----------------- Test Data as teller -----------------'
echo ''
echo ''
echo '28 - check cannot access customers - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM customer;"
echo ''
echo '29 - check account table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT "Teller_Account"(1);"
echo ''
echo '30 - check cannot access audit_trail - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '31 - check transactions_record table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT "Teller_Transaction"(1);"
echo ''
echo '32 - check employees table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT "Teller_Employee"(1);"
echo ''
echo '33 - check cannot access users - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '34 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '35 - check cannot access loan_information - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM loan_information;"
echo ''
echo ''
echo '----------------- Test Data as customers -----------------'
echo ''
echo ''
echo '36 - withdraw function - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "withdraw"(1);"
echo ''
echo '37 - deposit function - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "deposit"(1);"
echo ''
echo '38 - check customer table view - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "Customer_Customer"(1);"
echo ''
echo '39 - check account table view - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "Customer_Account"(1);"
echo ''
echo '40 - check cannot access audit_trail - expected outcome: fail'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '41 - check transactions_record table view - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "Customer_Transactions"(1);"
echo ''
echo '42 - check employees table view - expected outcome: fail'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT * FROM employees;"
echo ''
echo '43 - check cannot access users - expected outcome: fail'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '44 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '45 - check loan_information table view - expected outcome: success'
PGPASSWORD=complexpw psql -U pbrown -d 5528817 -c "SELECT "Customer_Loan"(1);"
echo ''
