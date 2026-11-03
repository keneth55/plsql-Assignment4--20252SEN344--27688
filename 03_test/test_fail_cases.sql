-- -- ERROR FIX: The original DDL created `customer` (singular), but the foreign key
-- -- and inserts use `customers`. Oracle would raise ORA-00942 because `customers`
-- -- did not exist. Use the same table name throughout.


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

 -- ACCOUNTS
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
INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
VALUES (106, 4, 'SAVINGS', 500000.00, 'ACTIVE', DATE '2024-05-05');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (107, 5, 'CURRENT', 0.00, 'CLOSED', DATE '2024-06-18');
 INSERT INTO accounts (account_id, customer_id, account_type, balance, status, opened_date)
 VALUES (108, 5, 'SAVINGS', 60000.00, 'ACTIVE', DATE '2024-06-20');

-- -- ERROR FIX: `txn_id` is a PRIMARY KEY with no default, so omitting it in the
-- -- original INSERTs attempts to insert NULL and raises ORA-01400. Supply a unique
-- -- txn_id for every transaction.
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


-- scenario the customer wants to see all there accounts and the total balance of all accounts
DECLARE
    TYPE account_record_t IS RECORD (
        account_id   accounts.account_id%TYPE,
        account_type accounts.account_type%TYPE,
        balance      accounts.balance%TYPE
    );
    TYPE account_collection_t IS TABLE OF account_record_t
        INDEX BY PLS_INTEGER;

    PROCEDURE validate_customer_id (
        p_customer_id IN customers.customer_id%TYPE
    ) IS
    BEGIN
        IF p_customer_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Customer ID cannot be NULL.');
        END IF;
    END validate_customer_id;

    PROCEDURE get_customer_accounts (
        p_customer_id IN customers.customer_id%TYPE,
        p_accounts    OUT account_collection_t
    ) IS
    BEGIN
        validate_customer_id(p_customer_id);

        SELECT account_id, account_type, balance
        BULK COLLECT INTO p_accounts
        FROM accounts
        WHERE customer_id = p_customer_id
        ORDER BY account_id;
    END get_customer_accounts;

    FUNCTION get_customer_total_balance (
        p_customer_id IN customers.customer_id%TYPE
    ) RETURN NUMBER IS
        v_total_balance NUMBER;
    BEGIN
        validate_customer_id(p_customer_id);

        SELECT NVL(SUM(balance), 0)
        INTO v_total_balance
        FROM accounts
        WHERE customer_id = p_customer_id;

        RETURN v_total_balance;
    END get_customer_total_balance;

    PROCEDURE show_customer_accounts (
        p_customer_id IN customers.customer_id%TYPE
    ) IS
        v_accounts      account_collection_t;
        v_total_balance NUMBER;
    BEGIN
        get_customer_accounts(p_customer_id, v_accounts);

        IF v_accounts.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No accounts found for customer ' || p_customer_id || '.');
            RETURN;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Accounts for customer ' || p_customer_id || ':');

        FOR i IN 1 .. v_accounts.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Account ID: ' || v_accounts(i).account_id
                || ', Type: ' || v_accounts(i).account_type
                || ', Balance: ' || NVL(v_accounts(i).balance, 0)
            );
        END LOOP;

        v_total_balance := get_customer_total_balance(p_customer_id);
        DBMS_OUTPUT.PUT_LINE('Total Balance: ' || v_total_balance);
    END show_customer_accounts;

    PROCEDURE run_tests IS
        v_accounts account_collection_t;
        v_total_balance NUMBER;
        e_invalid_customer_id EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_invalid_customer_id, -20001);
    BEGIN
        get_customer_accounts(4, v_accounts);
        v_total_balance := get_customer_total_balance(4);

        IF v_accounts.COUNT <> 1 OR v_total_balance <> 500000 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Success test failed for customer 4.');
        END IF;
        DBMS_OUTPUT.PUT_LINE('PASS: customer 4 account list and total balance.');

        BEGIN
            get_customer_accounts(NULL, v_accounts);
            RAISE_APPLICATION_ERROR(-20012, 'Expected NULL customer ID to be rejected by account retrieval.');
        EXCEPTION
            WHEN e_invalid_customer_id THEN
                DBMS_OUTPUT.PUT_LINE('PASS: account retrieval rejects a NULL customer ID.');
        END;

        BEGIN
            v_total_balance := get_customer_total_balance(NULL);
            RAISE_APPLICATION_ERROR(-20013, 'Expected NULL customer ID to be rejected by the balance function.');
        EXCEPTION
            WHEN e_invalid_customer_id THEN
                DBMS_OUTPUT.PUT_LINE('PASS: balance function rejects a NULL customer ID.');
        END;
    END run_tests;
BEGIN
    run_tests;
    show_customer_accounts(4); -- Change this to the customer_id to display.
END;
/
