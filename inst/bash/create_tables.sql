DROP TABLE IF EXISTS `surveys` ;

CREATE TABLE `surveys` (
  `id` TEXT PRIMARY KEY,
  `name` TEXT,
  `owner_id` TEXT,
  `last_modified` TEXT,
  `creation_date` TEXT,
  `is_active` INTEGER,
  `semester` TEXT NOT NULL,
  `year` REAL NOT NULL,
  `class` TEXT NOT NULL,
  `reliability` INTEGER NOT NULL,
  `created_at` TEXT NOT NULL DEFAULT current_timestamp,
  `updated_at` TEXT NOT NULL DEFAULT current_timestamp
);

create unique index ux_surveys_semester_year_class_reliability_is_active on `surveys` (semester, year, class, reliability, is_active) ;

CREATE TRIGGER update_surveys_updated_at
AFTER UPDATE ON surveys
WHEN old.updated_at <> current_timestamp
BEGIN
    UPDATE surveys
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = OLD.id;
END
;

DROP TABLE IF EXISTS `observations` ;

CREATE TABLE `observations` (
  `survey_id` TEXT,
  `start_date` TEXT,
  `end_date` TEXT,
  `status` TEXT,
  `ip_address` TEXT,
  `progress` INTEGER,
  `duration_in_seconds` INTEGER,
  `finished` INTEGER,
  `recorded_date` TEXT,
  `response_id` TEXT,
  `recipient_last_name` INTEGER,
  `recipient_first_name` INTEGER,
  `recipient_email` INTEGER,
  `external_reference` INTEGER,
  `location_latitude` REAL,
  `location_longitude` REAL,
  `distribution_channel` TEXT,
  `user_language` TEXT,
  `question` TEXT,
  `response` TEXT,
  FOREIGN KEY (survey_id) REFERENCES surveys (id)
);
