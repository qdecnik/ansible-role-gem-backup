#!/usr/bin/env ruby
# {{ ansible_managed }}

Model.new(:backup_{{ gem_backup_task_name }}, '{{ gem_backup_task_name }}') do

# split storage for Daily/Weekly/Monthly
time = Time.now
if time.day == 1
    storage_id = :monthly
    keep = {{ gem_backup_keep_monthly }}
elsif time.sunday?
    storage_id = :weekly
    keep = {{ gem_backup_keep_weekly }}
else
    storage_id = :daily
    keep = {{ gem_backup_keep_daily }}
end

{% if gem_backup_compress|bool %}
# compressors
{% include "include/compress.j2" %}
{% endif %}


{% if gem_backup_files|bool %}
# archives
{% include "include/archive_files.j2" %}
{% endif %}


{% if gem_backup_openldap|bool %}
# databases - OpenLDAP
{% include "include/db_openldap.j2" %}
{% endif %}


{% if gem_backup_postgres|bool %}
# databases - PostgreSQL
{% include "include/db_postgres.j2" %}
{% endif %}


{% if gem_backup_mysql|bool %}
# databases - MySQL
{% include "include/db_mysql.j2" %}
{% endif %}


{% if gem_backup_encrypt_openssl|bool %}
# encryptors - OpenSSL
{% include "include/encrypt_openssl.j2" %}
{% endif %}


{% if gem_backup_sftp|bool %}
# storages - SFTP
{% include "include/storage_sftp.j2" %}
{% endif %}


{% if gem_backup_ftp|bool %}
# storages - FTP
{% include "include/storage_ftp.j2" %}
{% endif %}


{% if gem_backup_s3|bool %}
# storages - S3
{% include "include/storage_s3.j2" %}
{% endif %}


{% if gem_backup_local|bool %}
# storages - local
{% include "include/storage_local.j2" %}
{% endif %}


{% if gem_backup_notify_mail|bool %}
# notifiers - email
{% include "include/notify_mail.j2" %}
{% endif %}


{% if gem_backup_notify_slack|bool %}
# notifiers - Slack
{% include "include/notify_slack.j2" %}
{% endif %}


{% if gem_backup_notify_zabbix|bool %}
# notifiers - Zabbix
{% include "include/notify_zabbix.j2" %}
{% endif %}

end
