 CREATE TABLE customers (
     customer_id   NUMBER PRIMARY KEY,
     first_name    VARCHAR2(50) NOT NULL,
     last_name     VARCHAR2(50) NOT NULL,
     email         VARCHAR2(100) UNIQUE,
     created_date  DATE DEFAULT SYSDATE
 );

 CREATE TABLE accounts (
     account_id    NUMBER PRIMARY KEY,
     customer_id   NUMBER NOT NULL REFERENCES customers(customer_id),
     account_type  VARCHAR2(10) CHECK (account_type IN ('SAVINGS','CURRENT')),
     balance       NUMBER(12,2) DEFAULT 0 CHECK (balance >= 0),
     status        VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CLOSED','FROZEN')),
    opened_date   DATE DEFAULT SYSDATE
 );

 CREATE TABLE transactions (
     txn_id        NUMBER PRIMARY KEY,
     account_id    NUMBER NOT NULL REFERENCES accounts(account_id),
     txn_type      VARCHAR2(15) CHECK (txn_type IN ('DEPOSIT','WITHDRAWAL','INTEREST','FEE')),
     amount        NUMBER(12,2) CHECK (amount > 0),
     txn_date      DATE DEFAULT SYSDATE
 );

 CREATE TABLE error_log (
     log_id        NUMBER PRIMARY KEY,
     proc_name     VARCHAR2(100),
     error_msg     VARCHAR2(4000),
     logged_at     DATE DEFAULT SYSDATE);
