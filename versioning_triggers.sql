USE
    acn_profile;
DELIMITER
    $$
CREATE TRIGGER trg_asset_insert AFTER INSERT ON
    asset FOR EACH ROW
BEGIN
    INSERT INTO asset_history(asset_id, operation, new_row)
VALUES(
    NEW.asset_id,
    'INSERT',
    JSON_OBJECT(
        'company_id',
        NEW.company_id,
        'asset_name',
        NEW.asset_name,
        'asset_type',
        NEW.asset_type,
        'environment',
        NEW.environment,
        'criticality',
        NEW.criticality,
        'owner_contact_id',
        NEW.owner_contact_id,
        'status',
        NEW.status
    )
) ; END $$
CREATE TRIGGER trg_asset_update AFTER UPDATE
ON
    asset FOR EACH ROW
BEGIN
    INSERT INTO asset_history(
        asset_id,
        operation,
        old_row,
        new_row
    )
VALUES(
    NEW.asset_id,
    'UPDATE',
    JSON_OBJECT(
        'company_id',
        OLD.company_id,
        'asset_name',
        OLD.asset_name,
        'asset_type',
        OLD.asset_type,
        'environment',
        OLD.environment,
        'criticality',
        OLD.criticality,
        'owner_contact_id',
        OLD.owner_contact_id,
        'status',
        OLD.status
    ),
    JSON_OBJECT(
        'company_id',
        NEW.company_id,
        'asset_name',
        NEW.asset_name,
        'asset_type',
        NEW.asset_type,
        'environment',
        NEW.environment,
        'criticality',
        NEW.criticality,
        'owner_contact_id',
        NEW.owner_contact_id,
        'status',
        NEW.status
    )
) ; END $$
CREATE TRIGGER trg_asset_delete AFTER DELETE
ON
    asset FOR EACH ROW
BEGIN
    INSERT INTO asset_history(asset_id, operation, old_row)
VALUES(
    OLD.asset_id,
    'DELETE',
    JSON_OBJECT(
        'company_id',
        OLD.company_id,
        'asset_name',
        OLD.asset_name,
        'asset_type',
        OLD.asset_type,
        'environment',
        OLD.environment,
        'criticality',
        OLD.criticality,
        'owner_contact_id',
        OLD.owner_contact_id,
        'status',
        OLD.status
    )
) ; END $$
DELIMITER
    ;
