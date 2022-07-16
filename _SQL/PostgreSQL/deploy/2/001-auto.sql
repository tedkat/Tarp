-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat Jul 16 08:41:24 2022
-- 
;
--
-- Table: c_accounts
--
CREATE TABLE "c_accounts" (
  "account_id" text NOT NULL,
  "parent_account_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("account_id")
);

;
--
-- Table: c_courses
--
CREATE TABLE "c_courses" (
  "course_id" text NOT NULL,
  "short_name" text NOT NULL,
  "long_name" text NOT NULL,
  "account_id" text NOT NULL,
  "term_id" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("course_id")
);

;
--
-- Table: c_enrollments
--
CREATE TABLE "c_enrollments" (
  "course_id" text NOT NULL,
  "user_id" text NOT NULL,
  "c_role" text NOT NULL,
  "role_id" text NOT NULL,
  "root_account" text NOT NULL,
  "section_id" text NOT NULL,
  "status" text NOT NULL,
  "associated_user_id" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("course_id", "user_id", "c_role", "section_id", "associated_user_id")
);

;
--
-- Table: c_sections
--
CREATE TABLE "c_sections" (
  "section_id" text NOT NULL,
  "course_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("section_id")
);

;
--
-- Table: c_terms
--
CREATE TABLE "c_terms" (
  "term_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("term_id")
);

;
--
-- Table: c_users
--
CREATE TABLE "c_users" (
  "user_id" text NOT NULL,
  "integration_id" text,
  "login_id" text NOT NULL,
  "authentication_provider_id" text NOT NULL,
  "password" text NOT NULL,
  "first_name" text NOT NULL,
  "last_name" text NOT NULL,
  "sortable_name" text NOT NULL,
  "short_name" text NOT NULL,
  "email" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("user_id")
);

;
--
-- Table: c_xlists
--
CREATE TABLE "c_xlists" (
  "xlist_course_id" text NOT NULL,
  "section_id" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("xlist_course_id", "section_id")
);

;
--
-- Table: s_queue
--
CREATE TABLE "s_queue" (
  "queue_id" bigserial NOT NULL,
  "username" text NOT NULL,
  "status" character(1) NOT NULL,
  "json_data" text NOT NULL,
  "zip_file" text NOT NULL,
  "queue_meta" text NOT NULL,
  "run_start" timestamp NOT NULL,
  "run_end" timestamp NOT NULL,
  "creation_ts" timestamp NOT NULL,
  "submitted_ts" timestamp,
  PRIMARY KEY ("queue_id")
);

;
--
-- Table: t_history_log
--
CREATE TABLE "t_history_log" (
  "histlog_id" bigserial NOT NULL,
  "domainspace" text NOT NULL,
  "nametag" text NOT NULL,
  "jsondata" text NOT NULL,
  "creation_ts" timestamp NOT NULL,
  PRIMARY KEY ("histlog_id")
);

;
--
-- Table: t_studentscores
--
CREATE TABLE "t_studentscores" (
  "score_type" text NOT NULL,
  "student_sis_id" text NOT NULL,
  "section_sis_id" text NOT NULL,
  "current_score" text NOT NULL,
  "point_possible" text NOT NULL,
  "extra" text NOT NULL,
  "is_dirty" character(1) NOT NULL,
  PRIMARY KEY ("score_type", "student_sis_id", "section_sis_id")
);

;
--
-- Table: tmp_accounts
--
CREATE TABLE "tmp_accounts" (
  "account_id" text NOT NULL,
  "parent_account_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("account_id")
);

;
--
-- Table: tmp_courses
--
CREATE TABLE "tmp_courses" (
  "course_id" text NOT NULL,
  "short_name" text NOT NULL,
  "long_name" text NOT NULL,
  "account_id" text NOT NULL,
  "term_id" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("course_id")
);

;
--
-- Table: tmp_enrollments
--
CREATE TABLE "tmp_enrollments" (
  "course_id" text NOT NULL,
  "user_id" text NOT NULL,
  "c_role" text NOT NULL,
  "role_id" text NOT NULL,
  "root_account" text NOT NULL,
  "section_id" text NOT NULL,
  "status" text NOT NULL,
  "associated_user_id" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("course_id", "user_id", "c_role", "section_id", "associated_user_id")
);

;
--
-- Table: tmp_sections
--
CREATE TABLE "tmp_sections" (
  "section_id" text NOT NULL,
  "course_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("section_id")
);

;
--
-- Table: tmp_terms
--
CREATE TABLE "tmp_terms" (
  "term_id" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL,
  "start_date" text NOT NULL,
  "end_date" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("term_id")
);

;
--
-- Table: tmp_users
--
CREATE TABLE "tmp_users" (
  "user_id" text NOT NULL,
  "login_id" text NOT NULL,
  "integration_id" text,
  "authentication_provider_id" text NOT NULL,
  "password" text NOT NULL,
  "first_name" text NOT NULL,
  "last_name" text NOT NULL,
  "sortable_name" text NOT NULL,
  "short_name" text NOT NULL,
  "email" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("user_id")
);

;
--
-- Table: tmp_xlists
--
CREATE TABLE "tmp_xlists" (
  "xlist_course_id" text NOT NULL,
  "section_id" text NOT NULL,
  "status" text NOT NULL,
  "extra" text NOT NULL,
  PRIMARY KEY ("xlist_course_id", "section_id")
);

;
