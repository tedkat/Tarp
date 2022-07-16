-- Convert schema '/opt/CanTarp/script/../_SQL/_source/deploy/1/001-auto.yml' to '/opt/CanTarp/script/../_SQL/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE c_users ADD COLUMN integration_id text;

;
ALTER TABLE tmp_users ADD COLUMN integration_id text;

;

COMMIT;

