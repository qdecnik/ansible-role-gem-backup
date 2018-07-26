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

    # compress archives
{% if gem_backup_compress|bool -%}
    compress_with Custom do |compression|
        compression.command = "{{ gem_backup_compress_type|d('gzip') }}"
        compression.extension = ".{{ gem_backup_compress_ext|d('gz') }}"
    end
{% endif %}

{% if gem_backup_mysql|bool -%}
{% if gem_backup_mysql_dump|bool %}
    # backup MySQL with mysqldump
    database MySQL do |db|
        db.host = "{{ gem_backup_mysql_db_host|default('localhost') }}"
        db.port = {{ gem_backup_mysql_db_port|default(3306) }}
        db.username = "{{ gem_backup_mysql_username }}"
        db.password = "{{ gem_backup_mysql_password }}"
    {% if gem_backup_mysql_db_name is defined and gem_backup_mysql_db_name|length > 0 -%}
        db.name = "{{ gem_backup_mysql_db_name }}"
    {% else %}
        db.name = :all
    {% endif %}
    {% if gem_backup_mysql_db_name is defined and gem_backup_mysql_db_name|length > 0 -%}
        db.additional_options = ['--quick', '--single-transaction', '--routines']
    {% else %}
        db.additional_options = ['--quick', '--single-transaction']
    {% endif %}
    end
{% endif %}
{% if gem_backup_mysql_xtrabackup|bool %}
    # backup MySQL with Percona XtraBackup
    database MySQL do |db|
        db.backup_engine = :innobackupex
        db.host = "{{ gem_backup_mysql_db_host|default('localhost') }}"
        db.port = "{{ gem_backup_mysql_db_port|default(3306) }}"
        db.username = "{{ gem_backup_mysql_username }}"
        db.password = "{{ gem_backup_mysql_password }}"
    {% if gem_backup_mysql_db_name is defined and gem_backup_mysql_db_name|length > 0 -%}
        db.name = "{{ gem_backup_mysql_db_name }}"
    {% else %}
        db.name = :all
    {% endif %}
        #db.prepare_options = ["--use-memory=4G"]
        db.verbose = true
    end
{% endif %}
{%- endif %}

{% if gem_backup_postgres|bool -%}
    # backup PostgreSQL
    database PostgreSQL do |db|
        db.host = "{{ gem_backup_postgres_db_host|default('localhost') }}"
        db.port = {{ gem_backup_postgres_db_port|default(5432) }}
        db.username = "{{ gem_backup_postgres_username }}"
        db.password = "{{ gem_backup_postgres_password }}"
{% if gem_backup_postgres_db_name is defined and gem_backup_postgres_db_name|length > 0 %}
        db.name = "{{ gem_backup_postgres_db_name }}"
{% else %}
        db.name = :all
{% endif %}
    end
{%- endif %}

{% if gem_backup_files|bool -%}
    # backup files
    archive :files do |archive|
        archive.tar_options '-p'
{% for item in gem_backup_files_add %}
        archive.add '{{ item }}'
{% endfor %}
{% if gem_backup_files_exclude|length > 0 %}
{% for item in gem_backup_files_exclude %}
        archive.exclude '{{ item }}'
{% endfor %}
{% endif %}
    end
{%- endif %}

{% if gem_backup_ftp|bool -%}
    # upload to FTP
    store_with FTP do |server|
        server.ip = "{{ gem_backup_ftp_host }}"
        server.port = {{ gem_backup_ftp_port|default(21) }}
        server.passive_mode = {{ gem_backup_ftp_passive_mode|lower|default(false) }}
        server.path = {{ gem_backup_ftp_path }}
        server.keep = {{ gem_backup_ftp_keep }}
        server.timeout = 30
        server.username = "{{ gem_backup_ftp_username }}"
        server.password = "{{ gem_backup_ftp_password }}"
    end
{%- endif %}

{% if gem_backup_sftp|bool -%}
    # upload to SFTP
    store_with SFTP do |server|
        server.ip = "{{ gem_backup_sftp_host }}"
        server.port = {{ gem_backup_sftp_port|default(22) }}
        server.keep = {{ gem_backup_sftp_keep }}
{% if gem_backup_sftp_path is defined %}
        server.path = "{{ gem_backup_sftp_path }}"
{% endif %}
        server.username = "{{ gem_backup_sftp_username }}"
{% if gem_backup_sftp_auth_by_pass %}
        server.password = "{{ gem_backup_sftp_password }}"
{% endif %}
    end
{%- endif %}

{% if gem_backup_local|bool -%}
    # upload to local
    store_with Local do |local|
        local.path = "{{ gem_backup_local_path }}"
        local.keep = {{ gem_backup_local_keep }}
    end
{%- endif %}

{% if gem_backup_notify_mail|bool -%}
    # send report to Mail
    notify_by Mail do |mail|
        mail.on_success = true
        mail.on_warning = true
        mail.on_failure = true
        mail.send_log_on = [:success, :warning, :failure]
        mail.from = "{{ gem_backup_notify_mail_from }}"
        mail.to = "{{ gem_backup_notify_mail_to }}"
    {% if gem_backup_notify_mail_cc|length > 0 %}
        mail.cc = "{{ gem_backup_notify_mail_cc }}"
    {% endif %}
        mail.address = "{{ gem_backup_notify_mail_host }}"
        mail.port = "{{ gem_backup_notify_mail_port }}"
        mail.domain = "{{ gem_backup_notify_mail_domain }}"
    end
{%- endif %}

{% if gem_backup_notify_slack|bool -%}
    # send report to Slack
    notify_by Slack do |slack|
        slack.on_success = {{ gem_backup_notify_slack_on_success|lower }}
        slack.on_warning = {{ gem_backup_notify_slack_on_warning|lower }}
        slack.on_failure = {{ gem_backup_notify_slack_on_failure|lower }}
        slack.webhook_url = "{{ gem_backup_notify_slack_url }}"
        slack.channel = "{{ gem_backup_notify_slack_channel }}"
        slack.username = "{{ gem_backup_notify_slack_botname }}"
    end
{%- endif %}

{% if gem_backup_notify_zabbix|bool -%}
    # send report to Zabbix
    notify_by Zabbix do |zabbix|
        zabbix.on_success = {{ gem_backup_notify_zabbix_on_success|lower }}
        zabbix.on_warning = {{ gem_backup_notify_zabbix_on_warning|lower }}
        zabbix.on_failure = {{ gem_backup_notify_zabbix_on_failure|lower }}
        zabbix.zabbix_host = "{{ gem_backup_notify_zabbix_hostname }}"
        zabbix.zabbix_port = {{ gem_backup_notify_zabbix_port|default(10051) }}
        zabbix.service_name = "{{ gem_backup_notify_zabbix_service_name|default('') }}"
        zabbix.service_host = "{{ gem_backup_notify_zabbix_service_host }}"
        zabbix.item_key = "{{ gem_backup_notify_zabbix_item_key }}"
    end
{%- endif %}

{% if gem_backup_encrypt_openssl|bool -%}
    # encrypt with OpenSSL
    # for decrypt run: openssl aes-256-cbc -d -base64 -in my_backup.tar.enc -out my_backup.tar
    encrypt_with OpenSSL do |encryption|
        encryption.password = '{{ gem_backup_encrypt_openssl_password }}'
        encryption.base64 = true
        encryption.salt = true
    end
{%- endif %}

end
