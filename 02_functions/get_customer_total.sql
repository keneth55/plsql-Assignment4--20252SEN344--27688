DECLARE
    TYPE account_record_t IS RECORD (
        account_id   accounts.account_id%TYPE,
        account_type accounts.account_type%TYPE,
        balance      accounts.balance%TYPE
    );
    TYPE account_collection_t IS TABLE OF account_record_t
        INDEX BY PLS_INTEGER;

    PROCEDURE get_customer_accounts (
        p_customer_id IN customers.customer_id%TYPE,
        p_accounts    OUT account_collection_t
    ) IS
    BEGIN
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
BEGIN
    show_customer_accounts(4); 
END;
/
