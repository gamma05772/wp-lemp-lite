#/bin/sh
MARIADB_DIR="/data/mariadb"
MARIADB_DB_NAME=${DB_NAME:-wordpress}
MARIADB_USER_NAME=${DB_USER:-wordpress}
MARIADB_USER_PASS=${DB_PASS:-secret}

if [ ! "$(ls -A $MARIADB_DIR)" ]; then
 su -s /bin/sh -c "mysql_install_db --datadir=$MARIADB_DIR --user=mysql" mysql
 mysqld --datadir=$MARIADB_DIR --user=mysql --wsrep_on=OFF --skip-networking --socket=/tmp/mysqld.sock &
 while [[ ! -S /tmp/mysqld.sock ]]; do sleep 1; done
 mysql --defaults-file=/etc/mysql/my.cnf --protocol=socket -uroot -hlocalhost --socket=/tmp/mysqld.sock <<EOF
  SET @@SESSION.SQL_LOG_BIN=0;
  INSTALL PLUGIN unix_socket SONAME 'auth_socket';
  TRUNCATE mysql.user;
  GRANT SHUTDOWN ON *.* TO 'mysql'@'localhost' IDENTIFIED VIA unix_socket;
  GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED VIA unix_socket WITH GRANT OPTION;
  CREATE DATABASE ${MARIADB_DB_NAME};
  GRANT ALL ON ${MARIADB_DB_NAME}.* TO '${MARIADB_USER_NAME}'@'localhost' IDENTIFIED BY '${MARIADB_USER_PASS}';
  DROP DATABASE IF EXISTS test;
  SHUTDOWN;
EOF
 wait
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf
