INSERT INTO rollups (name, event_table_name, event_id_sequence_name)
SELECT 'transactions_1day_rollup', 'transactions', 'transactions_id_seq'
UNION
SELECT 'last_user_transactions_rollup', 'transactions', 'transactions_id_seq';
