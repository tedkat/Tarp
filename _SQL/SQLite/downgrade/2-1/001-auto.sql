-- Convert schema '/opt/CanTarp/script/../_SQL/_source/deploy/2/001-auto.yml' to '/opt/CanTarp/script/../_SQL/_source/deploy/1/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE c_users_temp_alter (
  user_id text NOT NULL,
  login_id text NOT NULL,
  authentication_provider_id text NOT NULL,
  password text NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  sortable_name text NOT NULL,
  short_name text NOT NULL,
  email text NOT NULL,
  status text NOT NULL,
  extra text NOT NULL,
  is_dirty char(1) NOT NULL,
  PRIMARY KEY (user_id)
);

;
INSERT INTO c_users_temp_alter( user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra, is_dirty) SELECT user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra, is_dirty FROM c_users;

;
DROP TABLE c_users;

;
CREATE TABLE c_users (
  user_id text NOT NULL,
  login_id text NOT NULL,
  authentication_provider_id text NOT NULL,
  password text NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  sortable_name text NOT NULL,
  short_name text NOT NULL,
  email text NOT NULL,
  status text NOT NULL,
  extra text NOT NULL,
  is_dirty char(1) NOT NULL,
  PRIMARY KEY (user_id)
);

;
INSERT INTO c_users SELECT user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra, is_dirty FROM c_users_temp_alter;

;
DROP TABLE c_users_temp_alter;

;
CREATE TEMPORARY TABLE tmp_users_temp_alter (
  user_id text NOT NULL,
  login_id text NOT NULL,
  authentication_provider_id text NOT NULL,
  password text NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  sortable_name text NOT NULL,
  short_name text NOT NULL,
  email text NOT NULL,
  status text NOT NULL,
  extra text NOT NULL,
  PRIMARY KEY (user_id)
);

;
INSERT INTO tmp_users_temp_alter( user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra) SELECT user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra FROM tmp_users;

;
DROP TABLE tmp_users;

;
CREATE TABLE tmp_users (
  user_id text NOT NULL,
  login_id text NOT NULL,
  authentication_provider_id text NOT NULL,
  password text NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  sortable_name text NOT NULL,
  short_name text NOT NULL,
  email text NOT NULL,
  status text NOT NULL,
  extra text NOT NULL,
  PRIMARY KEY (user_id)
);

;
INSERT INTO tmp_users SELECT user_id, login_id, authentication_provider_id, password, first_name, last_name, sortable_name, short_name, email, status, extra FROM tmp_users_temp_alter;

;
DROP TABLE tmp_users_temp_alter;

;

COMMIT;

