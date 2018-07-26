#!/usr/bin/env ruby
# {{ ansible_managed }}

##
# Backup v4.x Configuration
#
# Documentation: http://backup.github.io/backup
# Issue Tracker: https://github.com/backup/backup/issues

root_path '{{ gem_backup_conf_dir }}'
tmp_path '{{ gem_backup_tmp_dir }}'

Logger.configure do
    console.quiet = false
    logfile.max_bytes = 2_000_000
    syslog.enabled = true
    syslog.ident = 'backup'
end
