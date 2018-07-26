# Ansible role: Gem-backup

Ansible role for [backup](http://backup.github.io/backup/v4/). Currently this works on Debian and RedHat based linux systems. Tested platforms are:

* Ubuntu 16.04
* Ubuntu 14.04
* Debian 9
* Debian 8
* CentOS 7
* CentOS 6

Requirements
------------

Requires Ruby; recommended role for Ruby installation: [geerlingguy.ruby](https://github.com/geerlingguy/ansible-role-ruby)

Role Variables
--------------

The variables that can be passed to this role and a brief description about them are as follows. (For all variables, take a look at defaults/main.yml)

```yaml
# cron task
gem_backup_cron_state: present
gem_backup_cron_hour: 1
gem_backup_cron_minute: 0

# backup PostgreSQL
gem_backup_postgres: true
gem_backup_postgres_db_host: localhost
gem_backup_postgres_db_port: 5432
gem_backup_postgres_username: postgres
gem_backup_postgres_password: postgres

# backup files
gem_backup_files: true
gem_backup_files_add:
  - /etc
  - /opt/some/app

gem_backup_compress: true
gem_backup_compress_type: pbzip2
gem_backup_compress_ext: bz2

# backup upload to local path
gem_backup_local: true
```

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: backup-client
  roles:
      - geerlingguy.ruby
      - mbaran0v.gem-backup
```

License
-------

MIT / BSD

Author Information
------------------

This role was created in 2018 by Maxim Baranov.
