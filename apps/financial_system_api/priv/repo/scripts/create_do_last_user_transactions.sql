CREATE OR REPLACE FUNCTION do_last_user_transactions(OUT start_id bigint, OUT end_id bigint)
RETURNS record
LANGUAGE plpgsql
AS $function$
BEGIN
    /* determine which page views we can safely aggregate */
    SELECT window_start, window_end INTO start_id, end_id
    FROM incremental_rollup_window('last_user_transactions_rollup');

    /* exit early if there are no new page views to aggregate */
    IF start_id > end_id THEN RETURN; END IF;

    /* aggregate the page views, merge results if the entry already exists */
    insert into last_user_transaction (user_id, last_transaction)
      select c.user_id
           , max(date_trunc('day', t.date_time)) as last_transaction       
        from transactions as t
       inner join accounts as c on c.id = t.account_id
       where t.id between start_id and end_id
       group by c.user_id
    on conflict (user_id) do
      update set last_transaction = excluded.last_transaction
      where last_user_transaction.last_transaction < excluded.last_transaction;
END;
$function$;
