# plsql-Assignment4--20252SEN344--27688


# Bank Database: Records and Collections in Oracle PL/SQL

**Course:** plsql
**Assignment:** IV - Records and Collections in Oracle PL/SQL
**Student:** TUMWINE Keneth & MUTAMBA Allice | **ID:** 20252SEN344 | 27688
**Date:** 3/11/2026

---

## 1. Project Overview

This project implements a small **banking system** in Oracle PL/SQL. It demonstrates records, collections, implicit and explicit cursors, bulk processing, stored procedures, functions, and exception handling, using realistic bank operations such as deposits, withdrawals, and monthly interest.

## 2. Database Schema

| Table | Purpose |
|---|---|
| `customers` | Bank customers (name, email, creation date) |
| `accounts` | Accounts owned by customers (type, balance, status) |
| `transactions` | History of deposits, withdrawals, interest, and fees |
| `error_log` | Records unexpected errors raised by procedures |

**Relationships:** one customer has many accounts, and one account has many transactions.

```
customers (1) ----< accounts (1) ----< transactions
```

**Sequences:** `txn_seq` (transaction IDs) and `log_seq` (error log IDs).

**Constraints used on purpose:**
- `CHECK (balance >= 0)` prevents negative balances.
- `CHECK (amount > 0)` rejects invalid transaction amounts.
- `CHECK` on `account_type`, `status`, and `txn_type` restricts values to valid options.
- These constraints also let us demonstrate bulk DML errors (`SAVE EXCEPTIONS`).

## 3. Requirements Coverage

| # | Requirement | Where it is demonstrated |
|---|---|---|
| 1 | Records | `%ROWTYPE` account record; user-defined `statement_rec` record; used inside procedures |
| 2 | Collections | Nested table of account IDs, associative array of balances, VARRAY of recent transactions |
| 3 | Implicit cursors | `deposit` / `close_account` using `SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND` |
| 4 | Explicit cursors | Parameterized cursor for a customer's accounts; cursor `FOR` loop for statements |
| 5 | Bulk processing | `BULK COLLECT` + `FORALL` in `apply_monthly_interest`, with `SAVE EXCEPTIONS` |
| 6 | Stored procedures | `deposit`, `withdraw`, `apply_monthly_interest`, `get_account_summary` |
| 7 | Functions | `get_balance`, `calc_interest`, `customer_total_balance` |
| 8 | Exception handling | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, user-defined exceptions, `RAISE_APPLICATION_ERROR` |

## 4. Stored Objects

### Procedures

| Name | Parameters | Description |
|---|---|---|
| `deposit` | `IN` account_id, amount | Adds money to an account and records the transaction |
| `withdraw` | `IN` account_id, amount | Removes money; raises an error on insufficient funds or a frozen account |
| `get_account_summary` | `IN` account_id; `OUT` name, balance, last_txn_date | Returns a summary using a record |
| `apply_monthly_interest` | `IN` rate; `OUT` accounts_processed | Applies interest to all active savings accounts using bulk processing |
| `close_account` | `IN` account_id | Closes an account using an implicit cursor check |

### Functions

| Name | Returns | Description |
|---|---|---|
| `get_balance(account_id)` | `NUMBER` | Current balance of an account |
| `calc_interest(balance, rate)` | `NUMBER` | Interest amount for a balance at a given rate |
| `customer_total_balance(customer_id)` | `NUMBER` | Sum of all active account balances for a customer |

## 5. Exception Handling Strategy

| Exception | Type | When it is raised |
|---|---|---|
| `NO_DATA_FOUND` | Predefined | Account or customer does not exist |
| `TOO_MANY_ROWS` | Predefined | A single-row query returns several rows |
| `insufficient_funds` | User-defined | Withdrawal exceeds the balance |
| `account_frozen` | User-defined | Operation attempted on a frozen or closed account |
| `ORA-24381` | Bulk DML | One or more rows failed in `FORALL ... SAVE EXCEPTIONS` |
| `WHEN OTHERS` | Catch-all | Logged to `error_log`, then **re-raised** (never silently ignored) |

Application errors use `RAISE_APPLICATION_ERROR` with codes in the range -20001 to -20999 and clear messages, for example:

| Code | Meaning |
|---|---|
| -20001 | Account not found |
| -20002 | Insufficient funds |
| -20003 | Account is frozen or closed |
| -20004 | Invalid amount |

## 6. Why Bulk Processing Is Faster

Row-by-row processing switches between the PL/SQL engine and the SQL engine **once per row**. Each switch has a cost, which adds up for thousands of rows. `BULK COLLECT` fetches all rows in one switch, and `FORALL` sends all DML statements in one switch. This reduces context switching and improves performance significantly on large data sets.

## 7. How to Run

Run the scripts in this order (SQL*Plus, SQL Developer, or Oracle Live SQL):

| Order | File | Content |
|---|---|---|
| 1 | `01_schema.sql` | Tables, constraints, sequences |
| 2 | `02_sample_data.sql` | Sample customers, accounts, transactions |
| 3 | `03_functions.sql` | Stored functions |
| 4 | `04_procedures.sql` | Stored procedures |
| 5 | `05_tests.sql` | Anonymous blocks that test everything |

Enable output before running tests:

```sql
SET SERVEROUTPUT ON;
```

## 8. Example Usage

**Call a function from SQL:**

```sql
SELECT account_id, get_balance(account_id) AS balance
FROM accounts;
```

**Call a function from a PL/SQL block:**

```sql
DECLARE
    v_total NUMBER;
BEGIN
    v_total := customer_total_balance(1);
    DBMS_OUTPUT.PUT_LINE('Total balance: ' || v_total);
END;
/
```

**Call a procedure with OUT parameters:**

```sql
DECLARE
    v_name  VARCHAR2(100);
    v_bal   NUMBER;
    v_date  DATE;
BEGIN
    get_account_summary(101, v_name, v_bal, v_date);
    DBMS_OUTPUT.PUT_LINE(v_name || ' has ' || v_bal);
END;
/
```

**Trigger an error on purpose (to show handling):**

```sql
BEGIN
    withdraw(101, 99999999);   -- expect: insufficient funds error
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```

## 9. Test Scenarios

| Scenario | Expected result |
|---|---|
| Deposit a valid amount | Balance increases; transaction row created |
| Deposit zero or a negative amount | Error -20004 |
| Withdraw more than the balance | Error -20002 |
| Operate on a non-existent account | Error -20001 |
| Operate on a frozen account | Error -20003 |
| Apply interest to all savings accounts | Balances updated; `INTEREST` transactions inserted |
| Bulk insert containing an invalid row | Bad row reported via `SAVE EXCEPTIONS`; valid rows succeed |

## 10. Notes and Assumptions

- Interest is applied only to `ACTIVE` accounts of type `SAVINGS`.
- Balances cannot go negative (enforced by a `CHECK` constraint and by procedure logic).
- Every procedure either completes fully or rolls back; errors are never hidden.
- Types declared inside PL/SQL blocks exist only for that block; schema-level types would be required to store collections in table columns.

## 11. Technologies

- Oracle Database (PL/SQL)
- SQL*Plus / Oracle SQL Developer
