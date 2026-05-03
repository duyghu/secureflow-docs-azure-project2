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
