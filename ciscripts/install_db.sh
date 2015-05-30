#!/bin/bash

set -eu
set -o pipefail


yum install -y mysql-server
service mysqld start

chkconfig --list mysqld
chkconfig mysqld on
chkconfig --list mysqld

mysql -uroot mysql <<EOS
GRANT ALL PRIVILEGES ON tiny_web_example.* TO root@'10.0.22.%';
FLUSH PRIVILEGES;
SELECT * FROM user WHERE User = 'root' \G
EOS


mysqladmin -uroot create tiny_web_example --default-character-set=utf8
