USE
    acn_profile;
CREATE OR REPLACE VIEW v_acn_profile_csv AS SELECT
    c.legal_name AS company_name,
    s.service_name,
    s.criticality AS service_criticality,
    GROUP_CONCAT(
        DISTINCT CONCAT(
            a.asset_name,
            '(',
            a.asset_type,
            ',crit=',
            a.criticality,
            ')'
        )
    ORDER BY
        a.criticality
    DESC SEPARATOR
        ' | '
    ) AS critical_assets,
    GROUP_CONCAT(
        DISTINCT CONCAT(
            tp.vendor_name,
            '(',
            tp.service_type,
            ')'
        )
    ORDER BY
        tp.vendor_name SEPARATOR ' | '
    ) AS third_parties,
    GROUP_CONCAT(
        DISTINCT CONCAT(
            cp.full_name,
            ' - ',
            cp.role_title,
            ' - ',
            cp.email
        )
    ORDER BY
        cp.is_primary
    DESC SEPARATOR
        ' | '
    ) AS contact_points
FROM
    company c
JOIN service s ON
    s.company_id = c.company_id
LEFT JOIN service_asset sa ON
    sa.service_id = s.service_id
LEFT JOIN asset a ON
    a.asset_id = sa.asset_id AND a.criticality >= 4
LEFT JOIN service_third_party stp ON
    stp.service_id = s.service_id
LEFT JOIN third_party tp ON
    tp.third_party_id = stp.third_party_id
LEFT JOIN contact_point cp ON
    cp.company_id = c.company_id
GROUP BY
    c.company_id,
    s.service_id;
    -- 1. Elenco asset critici per azienda
SELECT
    c.legal_name,
    a.asset_name,
    a.asset_type,
    a.criticality
FROM
    company c
JOIN asset a ON
    a.company_id = c.company_id
WHERE
    a.criticality >= 4
ORDER BY
    c.legal_name,
    a.criticality
DESC
    ;
    -- 2. Servizi erogati per azienda
SELECT
    c.legal_name,
    s.service_name,
    s.criticality
FROM
    company c
JOIN service s ON
    s.company_id = c.company_id
ORDER BY
    c.legal_name,
    s.criticality
DESC
    ;
    -- 3) Dipendenze da terze parti per servizio
SELECT
    c.legal_name,
    s.service_name,
    tp.vendor_name,
    tp.service_type
FROM
    company c
JOIN service s ON
    s.company_id = c.company_id
JOIN service_third_party stp ON
    stp.service_id = s.service_id
JOIN third_party tp ON
    tp.third_party_id = stp.third_party_id
ORDER BY
    c.legal_name,
    s.service_name;
