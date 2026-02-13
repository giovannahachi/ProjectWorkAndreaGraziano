USE
    acn_profile;
INSERT INTO company(legal_name, vat_number, sector)
VALUES(
    'Esempio S.p.A.',
    'IT12345678901',
    'ICT'
);
SET
    @CID := LAST_INSERT_ID();
INSERT INTO contact_point(
    company_id,
    full_name,
    role_title,
    email,
    phone,
    is_primary
)
VALUES(
    @CID,
    'Mario Rossi',
    'Security Officer',
    'm.rossi@esempio.it',
    '+39 02 000000',
    1
),(
    @CID,
    'Laura Bianchi',
    'IT Manager',
    'l.bianchi@esempio.it',
    '+39 02 111111',
    0
);
INSERT INTO third_party(
    company_id,
    vendor_name,
    service_type,
    contract_ref,
    contact_email
)
VALUES(
    @CID,
    'CloudyCloud',
    'CLOUD',
    'CC-2026-01',
    'support@cloudycloud.com'
),(
    @CID,
    'FibraTel',
    'ISP',
    'FT-2026-12',
    'noc@fibratel.it'
);
INSERT INTO service(
    company_id,
    service_name,
    description,
    criticality,
STATUS
)
VALUES(
    @CID,
    'Portale Clienti',
    'Gestione pratiche e area riservata',
    5,
    'ACTIVE'
),(
    @CID,
    'Posta Aziendale',
    'Email e calendari',
    4,
    'ACTIVE'
);
SELECT
    service_id
INTO @S1
FROM
    service
WHERE
    company_id = @CID AND service_name = 'Portale Clienti';
SELECT
    service_id
INTO @S2
FROM
    service
WHERE
    company_id = @CID AND service_name = 'Posta Aziendale';
INSERT INTO asset(
    company_id,
    asset_name,
    asset_type,
    environment,
    criticality,
    owner_contact_id,
STATUS
)
VALUES(
    @CID,
    'APP-PORTALE-01',
    'APP',
    'PROD',
    5,
    (
    SELECT
        contact_id
    FROM
        contact_point
    WHERE
        company_id = @CID AND email = 'l.bianchi@esempio.it'
),
'IN_USE'
),
(
    @CID,
    'DB-PORTALE-01',
    'DB',
    'PROD',
    5,
    (
    SELECT
        contact_id
    FROM
        contact_point
    WHERE
        company_id = @CID AND email = 'l.bianchi@esempio.it'
),
'IN_USE'
),
(
    @CID,
    'FW-EDGE-01',
    'FIREWALL',
    'PROD',
    4,
    (
    SELECT
        contact_id
    FROM
        contact_point
    WHERE
        company_id = @CID AND email = 'm.rossi@esempio.it'
),
'IN_USE'
);
SELECT
    asset_id
INTO @A_APP
FROM
    asset
WHERE
    company_id = @CID AND asset_name = 'APP-PORTALE-01';
SELECT
    asset_id
INTO @A_DB
FROM
    asset
WHERE
    company_id = @CID AND asset_name = 'DB-PORTALE-01';
SELECT
    asset_id
INTO @A_FW
FROM
    asset
WHERE
    company_id = @CID AND asset_name = 'FW-EDGE-01';
INSERT INTO service_asset(
    service_id,
    asset_id,
    role_in_service
)
VALUES(@S1, @A_APP, 'Frontend/Backend'),(@S1, @A_DB, 'Database'),(@S1, @A_FW, 'Perimetro');
INSERT INTO asset_dependency(
    from_asset_id,
    to_asset_id,
    dep_type
)
VALUES(@A_APP, @A_DB, 'DB');
INSERT INTO service_third_party(
    service_id,
    third_party_id,
    dep_notes
)
VALUES(
    @S1,
    (
    SELECT
        third_party_id
    FROM
        third_party
    WHERE
        company_id = @CID AND vendor_name = 'CloudyCloud'
),
'Hosting applicativo'
),
(
    @S1,
    (
    SELECT
        third_party_id
    FROM
        third_party
    WHERE
        company_id = @CID AND vendor_name = 'FibraTel'
),
'Connettività primaria'
);
