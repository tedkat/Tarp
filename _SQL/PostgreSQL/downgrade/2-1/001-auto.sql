-- Convert schema '/opt/CanTarp/script/../_SQL/_source/deploy/2/001-auto.yml' to '/opt/CanTarp/script/../_SQL/_source/deploy/1/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE c_users DROP COLUMN integration_id;

;
ALTER TABLE tmp_users DROP COLUMN integration_id;

;

COMMIT;

