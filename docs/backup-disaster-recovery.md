# Backup and Disaster Recovery

SecureFlow Docs includes a production-style backup and recovery posture for compute and data recovery.

## Implemented Controls

- Recovery Services Vault: `rsv-secureflow-dev-dr`
- VM backup policy: `bkpol-secureflow-dev-vm-daily`
- Vault storage redundancy: geo-redundant
- Vault soft delete: enabled
- VM backup schedule: daily at `23:00 UTC`
- Daily retention: `14` days
- Weekly retention: `4` weeks
- Azure SQL PITR retention: `14` days
- Azure SQL long-term retention:
  - Weekly backups: `4` weeks
  - Monthly backups: `3` months
  - Yearly backup: `1` year

## Recovery Objectives

- RPO target: less than `24 hours` for VM tier backup.
- SQL RPO target: Azure SQL automated backups with point-in-time restore.
- RTO target: restore database copy, validate records, then update application connection target during a controlled recovery.

## Azure Portal Demo Steps

1. Open Azure Portal.
2. Go to Resource groups.
3. Select `group1_final`.
4. Open `rsv-secureflow-dev-dr`.
5. Show soft delete enabled and geo-redundant vault storage.
6. Open Backup policies and show `bkpol-secureflow-dev-vm-daily`.
7. Open Azure SQL database `sqldb-secureflow-docs`.
8. Show Backup / Restore options and point-in-time restore availability.
9. Show the Azure Backup vault, SQL restore settings, and the documented restore evidence.

## Recovery Demonstration

Use a restored database copy for the class demonstration instead of damaging the live app database.

Suggested story:

1. Create a test document through the SecureFlow UI.
2. Record the document ID and title.
3. Delete the row from the active database during the demo window.
4. Restore the SQL database to a new database name using a timestamp before deletion.
5. Query the restored database and show the deleted record exists.
6. Explain that production cutover would update the app connection string after validation.

Example command shape:

```bash
az sql db restore \
  --dest-name sqldb-secureflow-docs-restore-demo \
  --edition Standard \
  --name sqldb-secureflow-docs \
  --resource-group group1_final \
  --server sql-secureflow-dev \
  --time "YYYY-MM-DDTHH:MM:SSZ"
```

Validation query:

```sql
SELECT id, title, owner_username, signer_email, created_at
FROM document_records
WHERE title LIKE '%Restore Drill%';
```

## CLI Validation

```bash
az backup vault show \
  --name rsv-secureflow-dev-dr \
  --resource-group group1_final \
  --query "{name:name,storage:properties.storageType,softDelete:properties.softDeleteFeatureState}" \
  -o table
```

```bash
az backup policy show \
  --name bkpol-secureflow-dev-vm-daily \
  --resource-group group1_final \
  --vault-name rsv-secureflow-dev-dr \
  -o table
```

```bash
az sql db show \
  --name sqldb-secureflow-docs \
  --resource-group group1_final \
  --server sql-secureflow-dev \
  --query "{name:name,status:status,backupStorageRedundancy:requestedBackupStorageRedundancy}" \
  -o table
```

## Demo Talk Track

- "SecureFlow has both infrastructure recovery and data recovery controls."
- "Azure Backup is represented by a Recovery Services Vault and a daily VM policy."
- "Azure SQL point-in-time restore protects us from accidental data deletion."
- "For the recovery drill, we delete a test record and restore the database to a new copy from before the deletion."
- "We validate the restored record before any application cutover."
