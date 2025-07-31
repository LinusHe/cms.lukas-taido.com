#!/bin/bash

# Setup cron jobs for CMS backups

echo "Setting up CMS backup cron jobs..."

# Create log directory
mkdir -p /root/cms.lukas-taido.com/backups/logs

# Add cron jobs
(crontab -l 2>/dev/null; cat << CRON_EOF
# CMS Backup Jobs
# Daily backup at 2:00 AM
0 2 * * * cd /root/cms.lukas-taido.com && ./backup-scripts/backup-cms.sh daily

# Weekly backup on Sundays at 3:00 AM  
0 3 * * 0 cd /root/cms.lukas-taido.com && ./backup-scripts/backup-cms.sh weekly

# Monthly backup on the 1st at 4:00 AM
0 4 1 * * cd /root/cms.lukas-taido.com && ./backup-scripts/backup-cms.sh monthly
CRON_EOF
) | crontab -

echo "✓ Cron jobs installed:"
crontab -l | grep backup-cms

echo ""
echo "Logs will be stored in: /root/cms.lukas-taido.com/backups/logs/"
echo "- Monthly log files (backup-YYYY-MM.log)"
echo "- Automatic cleanup after 30 days"
echo ""
echo "Test backup manually: ./backup-scripts/backup-cms.sh daily"
