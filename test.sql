USE acn_profile;

--  verifico se la view produce righe
SELECT COUNT(*) AS rows_in_view FROM v_acn_profile_csv;

-- Verifica del funzionamento del trigger storico 
UPDATE asset SET criticality = 4 WHERE asset_name='FW-EDGE-01';
SELECT * FROM asset_history ORDER BY changed_at DESC LIMIT 5;

-- verifica: i servizi senza azienda devono essere 0
SELECT COUNT(*) AS orphan_services
FROM service s LEFT JOIN company c ON c.company_id=s.company_id
WHERE c.company_id IS NULL;
