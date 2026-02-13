CREATE DATABASE IF NOT EXISTS acn_profile
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE acn_profile;

CREATE TABLE company (
  company_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  legal_name   VARCHAR(255) NOT NULL,
  vat_number   VARCHAR(32) UNIQUE,
  sector       VARCHAR(120),
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE contact_point (
  contact_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  company_id   BIGINT NOT NULL,
  full_name    VARCHAR(160) NOT NULL,
  role_title   VARCHAR(120) NOT NULL,
  email        VARCHAR(190) NOT NULL,
  phone        VARCHAR(40),
  is_primary   TINYINT(1) NOT NULL DEFAULT 0,

  CONSTRAINT fk_contact_company
    FOREIGN KEY (company_id) REFERENCES company(company_id)
    ON DELETE CASCADE,

  UNIQUE KEY uk_contact_email (company_id, email),
  KEY idx_contact_company (company_id)
) ENGINE=InnoDB;

CREATE TABLE third_party (
  third_party_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  company_id     BIGINT NOT NULL,
  vendor_name    VARCHAR(255) NOT NULL,
  service_type   ENUM('CLOUD','ISP','MSP','SAAS','SOFTWARE_HOUSE','OTHER') NOT NULL,
  contract_ref   VARCHAR(120),
  contact_email  VARCHAR(190),

  CONSTRAINT fk_thirdparty_company
    FOREIGN KEY (company_id) REFERENCES company(company_id)
    ON DELETE CASCADE,

  UNIQUE KEY uk_thirdparty (company_id, vendor_name, service_type),
  KEY idx_thirdparty_company (company_id)
) ENGINE=InnoDB;

CREATE TABLE service (
  service_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
  company_id    BIGINT NOT NULL,
  service_name  VARCHAR(255) NOT NULL,
  description   TEXT,
  criticality   TINYINT NOT NULL, -- 1..5
  status        ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',

  CONSTRAINT fk_service_company
    FOREIGN KEY (company_id) REFERENCES company(company_id)
    ON DELETE CASCADE,

  UNIQUE KEY uk_service_name (company_id, service_name),
  KEY idx_service_company (company_id),
  KEY idx_service_crit (company_id, criticality)
) ENGINE=InnoDB;

CREATE TABLE asset (
  asset_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  company_id      BIGINT NOT NULL,
  asset_name      VARCHAR(255) NOT NULL,
  asset_type      ENUM('SERVER','VM','DB','APP','FIREWALL','SWITCH','STORAGE','CLOUD_RESOURCE','OTHER') NOT NULL,
  environment     ENUM('PROD','TEST','DEV') NOT NULL DEFAULT 'PROD',
  criticality     TINYINT NOT NULL, -- 1..5
  owner_contact_id BIGINT NULL,
  status          ENUM('IN_USE','DISMISSED') NOT NULL DEFAULT 'IN_USE',

  CONSTRAINT fk_asset_company
    FOREIGN KEY (company_id) REFERENCES company(company_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_asset_owner
    FOREIGN KEY (owner_contact_id) REFERENCES contact_point(contact_id)
    ON DELETE SET NULL,

  UNIQUE KEY uk_asset_name (company_id, asset_name),
  KEY idx_asset_company (company_id),
  KEY idx_asset_crit (company_id, criticality),
  KEY idx_asset_owner (owner_contact_id)
) ENGINE=InnoDB;

CREATE TABLE service_asset (
  service_id      BIGINT NOT NULL,
  asset_id        BIGINT NOT NULL,
  role_in_service VARCHAR(120) NOT NULL,
  PRIMARY KEY (service_id, asset_id),

  CONSTRAINT fk_srvasset_service
    FOREIGN KEY (service_id) REFERENCES service(service_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_srvasset_asset
    FOREIGN KEY (asset_id) REFERENCES asset(asset_id)
    ON DELETE CASCADE,

  KEY idx_srvasset_asset (asset_id)
) ENGINE=InnoDB;

CREATE TABLE asset_dependency (
  from_asset_id BIGINT NOT NULL,
  to_asset_id   BIGINT NOT NULL,
  dep_type      ENUM('NETWORK','STORAGE','AUTH','DB','API','OTHER') NOT NULL,
  PRIMARY KEY (from_asset_id, to_asset_id),

  CONSTRAINT fk_dep_from
    FOREIGN KEY (from_asset_id) REFERENCES asset(asset_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_dep_to
    FOREIGN KEY (to_asset_id) REFERENCES asset(asset_id)
    ON DELETE CASCADE,

  KEY idx_dep_to (to_asset_id)
) ENGINE=InnoDB;

CREATE TABLE service_third_party (
  service_id     BIGINT NOT NULL,
  third_party_id BIGINT NOT NULL,
  dep_notes      VARCHAR(255),
  PRIMARY KEY (service_id, third_party_id),

  CONSTRAINT fk_srvtp_service
    FOREIGN KEY (service_id) REFERENCES service(service_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_srvtp_tp
    FOREIGN KEY (third_party_id) REFERENCES third_party(third_party_id)
    ON DELETE CASCADE,

  KEY idx_srv_tp_tp (third_party_id)
) ENGINE=InnoDB;

-- Storico (audit)
CREATE TABLE asset_history (
  history_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
  asset_id    BIGINT NOT NULL,
  changed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  operation   ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  old_row     JSON NULL,
  new_row     JSON NULL,
  KEY idx_asset_hist_asset (asset_id)
) ENGINE=InnoDB;
