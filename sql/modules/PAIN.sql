BEGIN;

CREATE OR REPLACE FUNCTION ar__get(in_id int) returns ar language sql as
$$
select * from ar where id = in_id;
$$;

update defaults set value = 'yes' where setting_key = 'module_load_ok';

COMMIT;
