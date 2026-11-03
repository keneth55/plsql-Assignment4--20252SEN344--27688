INSERT INTO customers (customer_id, first_name, last_name, email, created_date)
VALUES (1, 'Alice', 'Mutesi', 'alice.mutesi@mail.com', DATE '2024-01-10');
 INSERT INTO customers (customer_id, first_name, last_name, email, created_date)
 VALUES (2, 'Eric', 'Habimana', 'eric.habimana@mail.com', DATE '2024-02-15');
 INSERT INTO customers (customer_id, first_name, last_name, email, created_date)
 VALUES (3, 'Grace', 'Uwase', 'grace.uwase@mail.com', DATE '2024-03-20');
 INSERT INTO customers (customer_id, first_name, last_name, email, created_date)
 VALUES (4, 'David', 'Nkurunziza', 'david.nkurunziza@mail.com', DATE '2024-05-05');
 INSERT INTO customers (customer_id, first_name, last_name, email, created_date)
 VALUES (5, 'Sandra', 'Ishimwe', 'sandra.ishimwe@mail.com', DATE '2024-06-18');


 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (101, 1, 'SAVINGS', 150000.00, 'ACTIVE', DATE '2024-01-10');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (102, 1, 'CURRENT', 40000.00, 'ACTIVE', DATE '2024-01-12');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (103, 2, 'SAVINGS', 275000.50, 'ACTIVE', DATE '2024-02-15');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (104, 3, 'SAVINGS', 8000.00, 'ACTIVE', DATE '2024-03-20');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (105, 3, 'CURRENT', 12000.00, 'FROZEN', DATE '2024-03-22');
-INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (106, 4, 'SAVINGS', 500000.00, 'ACTIVE', DATE '2024-05-05');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (107, 5, 'CURRENT', 0.00, 'CLOSED', DATE '2024-06-18');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (108, 5, 'SAVINGS', 60000.00, 'ACTIVE', DATE '2024-06-20');


 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (1, 101, 'DEPOSIT', 100000.00, DATE '2024-01-10');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (2, 101, 'DEPOSIT', 60000.00, DATE '2024-03-01');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (3, 101, 'WITHDRAWAL', 10000.00, DATE '2024-04-12');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (4, 102, 'DEPOSIT', 50000.00, DATE '2024-01-15');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (5, 102, 'WITHDRAWAL', 10000.00, DATE '2024-02-20');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (6, 103, 'DEPOSIT', 275000.50, DATE '2024-02-15');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (7, 104, 'DEPOSIT', 8000.00, DATE '2024-03-20');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (8, 105, 'DEPOSIT', 12000.00, DATE '2024-03-22');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (9, 106, 'DEPOSIT', 500000.00, DATE '2024-05-05');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (10, 108, 'DEPOSIT', 60000.00, DATE '2024-06-20');
 INSERT INTO transactions (txn_id, account_id, txn_type, amount, txn_date)
 VALUES (11, 108, 'FEE', 500.00, DATE '2024-07-01');

 COMMIT;
