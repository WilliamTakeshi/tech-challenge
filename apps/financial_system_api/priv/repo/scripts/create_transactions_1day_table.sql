CREATE TABLE transactions_1day (
    transaction_day timestamp,
    currency varchar(255),
    credit float8,
    debit float8,
    primary key (transaction_day, currency)
);
