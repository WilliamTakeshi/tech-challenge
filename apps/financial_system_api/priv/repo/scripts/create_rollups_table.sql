CREATE TABLE rollups (
    name text primary key,
    event_table_name text not null,
    event_id_sequence_name text not null,
    last_aggregated_id bigint default 0
);
