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
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO users (username, password, role_id, last_login) VALUES ('pbrown', 'GkbfZ7Z7TD8j', 4, '2024-12-27 9:51:00'); INSERT INTO customers (forename, surname, dob, email, phone, address, user_id) VALUES ('Patricia', 'Brown', '1978-03-18', 'patricia.brown@example.com', '07956 789012', '789 Oak Lane, Anytown', 4);"
echo ''
echo '9 - create customer - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO customers (forename, surname, dob, email, phone, address, user_id) VALUES ('Patricia', 'Brown', '1978-03-18', 'patricia.brown@example.com', '07956 789012', '789 Oak Lane, Anytown', 4);"
echo ''
echo '10 - create account - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO account (customer_id, account_type, balance, open_date, account_status) VALUES (1, 'Savings', 1000.00, '2023-10-27', 'Active');"
echo ''
echo '11 - create account - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO account (customer_id, account_type, balance, open_date, account_status) VALUES (2, 'Shopping', 50.00, '2024-04-12', 'Active');"
echo ''
echo '12 - create transaction_record - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO transaction_records (account_id, transaction_type, transaction_timestamp, amount, payment_method, description) VALUES (1, 'Deposit', NOW(), 500.00, 'Cash', 'Cash deposit');"
echo ''
echo '13 - create loan_information - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO loan_information (account_id, original_amount, interest_rate, loan_term, start_date, end_date) VALUES (1, 50000.00, 0.05, '5 years', '2023-10-27', '2028-10-27');"
echo ''
echo '14 - view account audit trail - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT "account_audit_trail"(1);"
echo ''
echo '15 - check customer table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Customer;"
echo ''
echo '16 - check account table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Account;"
echo ''
echo '17 - check audit_trail table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Transaction;"
echo ''
echo '18 - check cannot insert audit trail - expected outcome: fail'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "INSERT INTO audit_trail (account_id, audit_timestamp, action_details, affected_record, old_data, new_data) VALUES (1, NOW(), 'Account balance updated', 'account', '1000.00', '1500.00');";
echo ''
echo '18.3 - check cannot update audit trail - expected outcome: fail'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SET action_details = 'Account balance updated','900.00','1600.00', WHERE audit_id = 1;";
echo ''
echo '18.6 - check cannot delete audit trail - expected outcome: fail'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "DELETE FROM audit_trail WHERE audit_id = 1;";
echo ''
echo '19 - check transactions_record table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Transaction;"
echo ''
echo '20 - check employees table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Employee;"
echo ''
echo '21 - check users table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Users;"
echo ''
echo '22 - check user_roles table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_UserRoles;"
echo ''
echo '23 - check loan_information table view - expected outcome: success'
PGPASSWORD=WLNHj3RdEQ5F psql -U bjones -d 5528817 -c "SELECT * FROM BankManager_Loan;"
echo ''
echo ''
echo '----------------- Test Data as loan officer -----------------'
echo ''
echo ''
echo '24 - check customer table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM LoanOfficer_Customer;"
echo ''
echo '25 - check account table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM LoanOfficer_Account;"
echo ''
echo '26 - check cannot access audit_Trail - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '27 - check transactions_record table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM LoanOfficer_Transaction;"
echo ''
echo '28 - check employees table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM LoanOfficer_Employee;"
echo ''
echo '29 - check cannot access users - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '30 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '31 - check loan_information table view - expected outcome: success'
PGPASSWORD=yLBZNz39TZTK psql -U jdoe -d 5528817 -c "SELECT * FROM LoanOfficer_Loan;"
echo ''
echo ''
echo '----------------- Test Data as teller -----------------'
echo ''
echo ''
echo '32 - check cannot access customers - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM customers;"
echo ''
echo '33 - check account table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM Teller_Account;"
echo ''
echo '34 - check cannot access audit_trail - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '35 - check transactions_record table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM Teller_Transaction;"
echo ''
echo '36 - check employees table view - expected outcome: success'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM Teller_Employee;"
echo ''
echo '37 - check cannot access users - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '38 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '39 - check cannot access loan_information - expected outcome: fail'
PGPASSWORD=AN8jv2uZvyaJ psql -U cjohnson -d 5528817 -c "SELECT * FROM loan_information;"
echo ''
echo ''
echo '----------------- Test Data as customers -----------------'
echo ''
echo ''
echo '40 - withdraw function - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT "withdraw"(1);"
echo ''
echo '41 - deposit function - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT "deposit"(1);"
echo ''
echo '42 - check customer table view - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM Customer_Customer;"
echo ''
echo '43 - check account table view - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM Customer_Account;"
echo ''
echo '44 - check cannot access audit_trail - expected outcome: fail'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM audit_trail;"
echo ''
echo '45 - check transactions_record table view - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM Customer_Transaction;"
echo ''
echo '46 - check employees table view - expected outcome: fail'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM employees;"
echo ''
echo '47 - check cannot access users - expected outcome: fail'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM users;"
echo ''
echo '48 - check cannot access user_roles - expected outcome: fail'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM user_roles;"
echo ''
echo '49 - check loan_information table view - expected outcome: success'
PGPASSWORD=GkbfZ7Z7TD8j psql -U pbrown -d 5528817 -c "SELECT * FROM Customer_Loan;"
echo ''
echo ''
