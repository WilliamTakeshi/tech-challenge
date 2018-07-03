CREATE OR REPLACE FUNCTION do_transactions_aggregations(OUT start_id bigint, OUT end_id bigint)
RETURNS record
LANGUAGE plpgsql
AS $function$
BEGIN
    /* determine which page views we can safely aggregate */
    SELECT window_start, window_end INTO start_id, end_id
    FROM incremental_rollup_window('transactions_1day_rollup');

    /* exit early if there are no new page views to aggregate */
    IF start_id > end_id THEN RETURN; END IF;

    /* aggregate the page views, merge results if the entry already exists */
    INSERT INTO transactions_1day (transaction_day, currency, credit, debit)
      select date_trunc('day', t.date_time)
           , c.currency
           , sum(GREATEST(t.value, 0)) as credit
           , abs(sum(LEAST(t.value, 0))) as debit       
        from transactions as t
       inner join accounts c on c.id = t.account_id
       where t.id between start_id and end_id

       group by date_trunc('day', t.date_time), c.currency 

      ON CONFLICT (transaction_day, currency) DO UPDATE
      SET credit = transactions_1day.credit + EXCLUDED.credit
        , debit = transactions_1day.debit + EXCLUDED.debit;
END;
$function$;
