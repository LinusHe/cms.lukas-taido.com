# Restore Backup Instructions

This document provides instructions for restoring your CMS backups.

## Restoring MongoDB Backup
1. Locate your MongoDB backup file in the `backups` folder.
   - Example: `backups/daily/db-YYYY-MM-DD_HH-MM-SS.gz`
   
2. Use the following command to restore MongoDB:
   ```bash
   docker exec -i cmslukas-taidocom_mongo_1 mongorestore --db payload --drop --gzip --archive ^?< YOUR_BACKUP_FILE
   ```
   - Replace `YOUR_BACKUP_FILE` with the path to your `.gz` file.
   - The `--drop` option will drop the existing database before restoring (use with caution).

## Restoring Media or Documents
1. Locate your media/documents backup file in the `backups` folder.
   - Example: `backups/daily/media-YYYY-MM-DD_HH-MM-SS.tar.gz`

2. Extract the backup file:
   ```bash
   tar -xzf YOUR_MEDIA_BACKUP_FILE -C /path/to/restore/
   ```
   - Replace `YOUR_MEDIA_BACKUP_FILE` with the path to your media or documents `.tar.gz` file.
   - Adjust `/path/to/restore/` to the desired destination directory.

3. Confirm files are correctly restored in the destination.

---

Ensure the CMS services are up and running after the restoration. If there are any issues, check the logs and configurations.