
# Implementation Documentation
## Oracle PL/SQL Banking Account Management System

## 1. Project Overview

The Oracle PL/SQL Banking Account Management System is designed to manage customer information, bank accounts, and financial transactions.

The main functionality implemented in this program allows a customer to:
- View all their bank accounts.
- Retrieve account details, including account ID, account type, and balance.
- Calculate the total balance across all their accounts.
- Validate customer IDs before retrieving account information.

The system uses Oracle SQL for data storage and PL/SQL for procedural logic, validation, data retrieval, and testing.

---

## 2. Technologies Used

| Technology | Purpose |
|---|---|
| Oracle Database | Stores customer, account, and transaction information |
| SQL | Creates tables and inserts records |
| PL/SQL | Implements procedures, functions, and validation |
| DBMS_OUTPUT | Displays account information and test results |
| SQL Developer / SQL*Plus | Executes and tests the program |

---

## 3. Database Structure

The system uses three main tables.

### 3.1 Customers Table

The `customers` table stores customer information.

| Column | Description |
|---|---|
| customer_id | Unique identifier for each customer |
| first_name | Customer's first name |
| last_name | Customer's last name |
| email | Customer's email address |
| created_date | Date the customer was registered |

### 3.2 Accounts Table

The `accounts` table stores bank account information.

| Column | Description |
|---|---|
| account_id | Unique identifier for each account |
| customer_id | Identifies the account owner |
| account_type | Type of account, such as SAVINGS or CURRENT |
| balance | Current account balance |
| status | Account status, such as ACTIVE, FROZEN, or CLOSED |
| opened_date | Date the account was opened |

The `customer_id` column establishes a relationship between the `accounts` and `customers` tables.

One customer can have multiple bank accounts.

### 3.3 Transactions Table

The `transactions` table stores financial transaction records.

| Column | Description |
|---|---|
| txn_id | Unique identifier for each transaction |
| account_id | Identifies the account involved |
| txn_type | Type of transaction |
| amount | Amount involved in the transaction |
| txn_date | Date the transaction occurred |

The `account_id` column links each transaction to its corresponding bank account.

---

## 4. Database Initialization and Sample Data

The implementation begins by inserting sample records into the database.

### 4.1 Customer Data Insertion

Five customers are inserted into the `customers` table.

The records include customer IDs, names, email addresses, and registration dates.

Example:

```sql
INSERT INTO customers
(customer_id, first_name, last_name, email, created_date)
VALUES
(1, 'Alice', 'Mutesi', 'alice.mutesi@mail.com',
 DATE '2024-01-10');
```

The `DATE` literal is used to insert dates in a reliable Oracle-supported format.

### 4.2 Account Data Insertion

Eight bank accounts are inserted into the `accounts` table.

The sample data includes:
- Savings accounts
- Current accounts
- Active accounts
- Frozen accounts
- Closed accounts

Each account is associated with an existing customer through its `customer_id`.

### 4.3 Transaction Data Insertion

Eleven transactions are inserted into the `transactions` table.

The transaction types include:
- DEPOSIT
- WITHDRAWAL
- FEE

Each transaction is assigned a unique `txn_id` because the primary key does not automatically generate a value.

### 4.4 Data Consistency Fixes

Two important corrections were made to the original SQL implementation.

**Correction 1: Consistent table naming**

The original code used `customer` in the table creation statement but `customers` in the foreign key and insertion statements.

The implementation uses `customers` consistently to prevent Oracle error `ORA-00942`.

**Correction 2: Unique transaction IDs**

The original transaction insertion statements omitted `txn_id`.

Since `txn_id` is a primary key without an automatic default, this could cause `ORA-01400`.

The corrected implementation supplies a unique transaction ID for every transaction.

Finally, the `COMMIT` statement permanently saves the inserted records.

---

## 5. PL/SQL Implementation

The main PL/SQL block implements customer account retrieval, balance calculation, validation, and testing.

### 5.1 Account Record Type

```sql
TYPE account_record_t IS RECORD (
    account_id   accounts.account_id%TYPE,
    account_type accounts.account_type%TYPE,
    balance      accounts.balance%TYPE
);
```

This statement defines a custom record type named `account_record_t`.

The record contains three fields:

- `account_id`: Stores the account identifier.
- `account_type`: Stores the type of account.
- `balance`: Stores the account balance.

The `%TYPE` attribute allows each field to inherit the data type of its corresponding database column.

This reduces data type mismatches and makes the program easier to maintain.

### 5.2 Account Collection Type

```sql
TYPE account_collection_t IS TABLE OF account_record_t
    INDEX BY PLS_INTEGER;
```

This defines an associative array that stores multiple account records.

The collection is indexed using `PLS_INTEGER`, allowing the program to access individual account records using numeric indexes.

For example:

```sql
v_accounts(1).account_id
```

This accesses the account ID stored in the first record of the collection.

---

## 6. Customer ID Validation

### Procedure: `validate_customer_id`

```sql
PROCEDURE validate_customer_id (
    p_customer_id IN customers.customer_id%TYPE
) IS
BEGIN
    IF p_customer_id IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Customer ID cannot be NULL.'
        );
    END IF;
END validate_customer_id;
```

### Purpose

This procedure ensures that a customer ID is provided before the system attempts to retrieve account information.

### Implementation Logic

1. Receive the customer ID as an input parameter.
2. Check whether the customer ID is NULL.
3. If it is NULL, raise a custom Oracle application error.
4. If it is valid, allow the program to continue.

### Error Handling

The program uses error code `-20001` to indicate that a NULL customer ID is not allowed.

This prevents the system from performing account retrieval or balance calculations without a valid customer identifier.

---

## 7. Retrieving Customer Accounts

### Procedure: `get_customer_accounts`

```sql
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
```

### Purpose

This procedure retrieves all accounts belonging to a specified customer.

### Parameters

| Parameter | Mode | Description |
|---|---|---|
| p_customer_id | IN | Customer whose accounts are requested |
| p_accounts | OUT | Collection containing the retrieved accounts |

### Implementation Logic

1. Receive the customer ID.
2. Validate the customer ID using `validate_customer_id`.
3. Query the `accounts` table.
4. Retrieve accounts belonging to the specified customer.
5. Store the results in the `p_accounts` collection.
6. Sort the results by account ID.

### Use of BULK COLLECT

`BULK COLLECT` retrieves multiple database records into a PL/SQL collection in one operation.

This is useful because a customer may own more than one account.

Instead of retrieving records individually, the procedure collects all matching accounts into `p_accounts`.

---

## 8. Calculating the Total Customer Balance

### Function: `get_customer_total_balance`

```sql
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
```

### Purpose

This function calculates the combined balance of all accounts belonging to a customer.

### Implementation Logic

1. Receive the customer ID.
2. Validate the customer ID.
3. Retrieve all account balances belonging to the customer.
4. Use `SUM(balance)` to calculate the total.
5. Use `NVL` to return zero if the result is NULL.
6. Return the calculated total balance.

### SQL Functions Used

**SUM()**

Calculates the total of all account balances associated with a customer.

**NVL()**

Replaces a NULL result with zero.

For example:

```sql
NVL(SUM(balance), 0)
```

This ensures that a customer with no accounts receives a total balance of `0` rather than NULL.

### Function Return Value

The function returns a numeric value representing the total balance across the customer's accounts.

---

## 9. Displaying Customer Accounts

### Procedure: `show_customer_accounts`

```sql
PROCEDURE show_customer_accounts (
    p_customer_id IN customers.customer_id%TYPE
) IS
    v_accounts      account_collection_t;
    v_total_balance NUMBER;
BEGIN
    get_customer_accounts(p_customer_id, v_accounts);

    IF v_accounts.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'No accounts found for customer '
            || p_customer_id || '.'
        );
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Accounts for customer ' || p_customer_id || ':'
    );

    FOR i IN 1 .. v_accounts.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Account ID: ' || v_accounts(i).account_id
            || ', Type: ' || v_accounts(i).account_type
            || ', Balance: ' || NVL(v_accounts(i).balance, 0)
        );
    END LOOP;

    v_total_balance := get_customer_total_balance(p_customer_id);

    DBMS_OUTPUT.PUT_LINE(
        'Total Balance: ' || v_total_balance
    );
END show_customer_accounts;
```

### Purpose

This procedure combines account retrieval and balance calculation to display all accounts belonging to a customer.

### Implementation Logic

1. Call `get_customer_accounts` to retrieve the customer's accounts.
2. Check whether the collection contains any records.
3. If no accounts exist, display a message and terminate the procedure.
4. Otherwise, display the customer's account information.
5. Use a `FOR` loop to process each account record.
6. Display the account ID, account type, and balance.
7. Call `get_customer_total_balance`.
8. Display the total balance of all accounts.

### Use of DBMS_OUTPUT

`DBMS_OUTPUT.PUT_LINE` displays messages and account information during program execution.

This allows the user to view the results directly in Oracle SQL Developer or SQL*Plus.

---

## 10. Testing and Validation

### Procedure: `run_tests`

The testing procedure verifies that the account retrieval and balance calculation functions behave as expected.

### 10.1 Successful Account Retrieval Test

```sql
get_customer_accounts(4, v_accounts);

v_total_balance := get_customer_total_balance(4);

IF v_accounts.COUNT <> 1
   OR v_total_balance <> 500000 THEN
    RAISE_APPLICATION_ERROR(
        -20010,
        'Success test failed for customer 4.'
    );
END IF;
```

This test checks customer ID `4`.

According to the sample data, customer 4 owns one savings account with a balance of `500000.00`.

The test verifies that:
- Exactly one account is retrieved.
- The total balance equals `500000`.

If both conditions are satisfied, the program displays:

```text
PASS: customer 4 account list and total balance.
```

### 10.2 NULL Customer ID Test for Account Retrieval

```sql
BEGIN
    get_customer_accounts(NULL, v_accounts);

    RAISE_APPLICATION_ERROR(
        -20012,
        'Expected NULL customer ID to be rejected.'
    );

EXCEPTION
    WHEN e_invalid_customer_id THEN
        DBMS_OUTPUT.PUT_LINE(
            'PASS: account retrieval rejects a NULL customer ID.'
        );
END;
```

This test verifies that the account retrieval procedure rejects a NULL customer ID.

The expected error is `-20001`.

If the procedure correctly raises this error, the test passes.

### 10.3 NULL Customer ID Test for Balance Calculation

```sql
BEGIN
    v_total_balance := get_customer_total_balance(NULL);

    RAISE_APPLICATION_ERROR(
        -20013,
        'Expected NULL customer ID to be rejected.'
    );

EXCEPTION
    WHEN e_invalid_customer_id THEN
        DBMS_OUTPUT.PUT_LINE(
            'PASS: balance function rejects a NULL customer ID.'
        );
END;
```

This test verifies that the balance calculation function also rejects NULL customer IDs.

It ensures that both account retrieval and balance calculation use the same validation logic.

### 10.4 Custom Exception Handling

```sql
e_invalid_customer_id EXCEPTION;

PRAGMA EXCEPTION_INIT(
    e_invalid_customer_id,
    -20001
);
```

The `PRAGMA EXCEPTION_INIT` statement associates the custom exception name with Oracle error code `-20001`.

This allows the test procedure to catch the expected validation error and report a successful test instead of terminating unexpectedly.

---

## 11. Main Program Execution

The final section of the PL/SQL block executes the tests and displays account information.

```sql
BEGIN
    run_tests;

    show_customer_accounts(4);
END;
/
```

### Execution Sequence

1. Execute `run_tests`.
2. Verify account retrieval for customer 4.
3. Verify the total balance for customer 4.
4. Verify that NULL customer IDs are rejected.
5. Display all accounts belonging to customer 4.
6. Display the customer's total balance.

The customer ID can be changed to display the accounts of another customer.

For example:

```sql
show_customer_accounts(1);
```

This displays all accounts belonging to customer 1.

---

## 12. Expected Output

When the main program is executed successfully, the expected output is:

```text
PASS: customer 4 account list and total balance.
PASS: account retrieval rejects a NULL customer ID.
PASS: balance function rejects a NULL customer ID.

Accounts for customer 4:
Account ID: 106, Type: SAVINGS, Balance: 500000

Total Balance: 500000
```

The exact numeric formatting may vary depending on Oracle's output settings.

---

## 13. Implementation Limitations

The current implementation has the following limitations:

1. It retrieves account information but does not perform deposits or withdrawals.
2. It does not update account balances based on transaction records.
3. It does not verify whether a customer exists before retrieving accounts.
4. It does not filter accounts based on their status.
5. It displays results through `DBMS_OUTPUT` rather than a graphical user interface.
6. The sample data is designed for testing and does not represent a production banking environment.

**Important:** The transaction records and account balances are inserted independently. The current implementation does not calculate account balances from transaction history.

---

## 14. Future Improvements

The system can be improved by implementing:

- Deposit and withdrawal procedures.
- Transaction history retrieval.
- Automatic account balance updates.
- Customer existence validation.
- Account status validation.
- Exception handling for insufficient funds.
- Account transfer functionality.
- A graphical user interface.
- Additional automated testing.
- Database security and access control.

---

## 15. Conclusion

The Oracle PL/SQL Banking Account Management System demonstrates how procedural SQL can be used to retrieve customer accounts, calculate account balances, validate input, and test database operations.

The implementation uses PL/SQL records, associative arrays, procedures, functions, SQL aggregate functions, and exception handling to provide a structured and reusable solution.

The system provides a foundation for further development into a more comprehensive banking management application.
