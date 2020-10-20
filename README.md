# xtrabackup

![ansible ci](https://github.com/link-u/ansible-roles-v2_xtrabackup/workflows/ansible%20ci/badge.svg)

## 概要

percona-cluster の backup設定用 role

gdriveを使用したGoogleDriveへのアップロードについて

* gdriveのアップロード対象は一台になります
* どのノードからアップロードするかは変数で指定する必要があります
* 初回ansible実行時は認証キーを取得し、入力する必要があります

## 動作確認バージョン

* Ubuntu 18.04 (bionic)
* ansible >= 2.8
* Jinja2 2.10.3

## 使い方 (ansible)

### Role variables

```yaml
### インストール設定 ###############################################################################
xtrabackup_install_flag: True
xtrabackup_cron_file: /etc/cron.d/xtrabackup
xtrabackup_db_user: root
xtrabackup_db_host: 127.0.0.1

## mysql (percona) の root のパスワード
#  * root のパスワードのデフォルト値はダミーのものを設定している.
#  * 環境に合わせて設定すること
xtrabackup_db_password: "{{ pxc_root_password | default('default&root&password') }}"

xtrabackup_target_dir: /var/lib/xtrabackup
xtrabackup_user: root


### 追加設定 ######################################################################################
# バックアップを実行するホスト
xtrabackup_target_hosts: "{{ ansible_play_hosts }}"

# 1時間ごとのincremental backupを行うかどうか
xtrabackup_does_hourly_backup: yes

# clean backup files
xtrabackup_scripts_dir: "{{ xtrabackup_target_dir }}/scripts"

xtrabackup_datetimes:
  full:
    days_duration: 7 # この日数経過後にバックアップを削除
    removing_hour: 2 # 削除処理の実行時刻
    creating_hour: 4 # バックアップ処理の実行時刻
  incremental:
    days_duration: 5
    removing_hour: 2
    # 作成は毎時行われるのでcreating_hourは無し

xtrabackup_encrypt_password: "default&encrypt&password"

# リストアスクリプトに使用
xtrabackup_mysql_pidfile: /var/run/mysqld/mysqld.pid
xtrabackup_mysql_datadir: /var/lib/mysql

# 圧縮するかどうか
xtrabackup_compressed_backup: yes
xtrabackup_compressed_full_backup: "{{ xtrabackup_compressed_backup }}"
xtrabackup_compressed_incremental_backup: "{{ xtrabackup_compressed_backup }}"
# --compress-threadsの数
xtrabackup_compressed_threads: 4
xtrabackup_compressed_full_backup_threads: "{{ xtrabackup_compressed_threads }}"
xtrabackup_compressed_incremental_backup_threads: "{{ xtrabackup_compressed_threads }}"
```

### Example playbook

```yaml
- hosts: servers
  roles:
    - { role: xtrabackup, tags: [ "xtrabackup" ] }
```

## 後方互換性について

### 削除された変数の一覧

以下の変数は `group_vars` から削除して頂いて大丈夫です.

* `xtrabackup_package_install`
  * この変数は既に percona xtradb cluster がインストールされている場合, 
    再度インストールをしないようにするための設定であるが, 
    インストールに関して冪等性が担保されているのでこの変数の存在する意味が特にないため,  
    この変数を削除しました.
