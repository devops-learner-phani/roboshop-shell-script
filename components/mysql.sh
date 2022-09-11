#source components/common.sh
#
#CHECK_ROOT
#
#if [ -z "${MYSQL_PASSWORD}" ]; then
#  echo "Needed MYSQL_PASSWORD variable"
#  exit 1
#fi
#
#PRINT "Configure yum repos"
#curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG}
#CHECK_STAT $?
#
#PRINT "Install mysql server"
#yum install mysql-community-server -y &>>${LOG}
#CHECK_STAT $?
#
#PRINT "Start the mysql service"
#systemctl enable mysqld &>>${LOG} && systemctl restart mysqld &>>${LOG}
#CHECK_STAT $?
#
#MYSQL_DEFAULT_PASSWORD=$( grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}') &>>${LOG}
#
#echo show databases | mysql -uroot -p"${MYSQL_PASSWORD}" &>>${LOG}
#if [ $? -ne 0 ]; then
#  PRINT "Reset MYSQL_PASSWORD"
#  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" | mysql --connect-expired-password  -uroot -p"${MYSQL_DEFAULT_PASSWORD}" &>>${LOG}
#  CHECK_STAT $?
#fi
#
#echo show plugins | mysql -uroot -pRoboShop@1 2>>${LOG} | grep validate_password &>>${LOG}
#if [ $? -ne 0 ]; then
#  PRINT "uninstall Validate password plugin"
#  echo "uninstall plugin validate_password;" | mysql -uroot -p"${MYSQL_PASSWORD}" &>>${LOG}
#  CHECK_STAT $?
#fi
#
#
#PRINT "Download Schema"
#curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>${LOG}
#CHECK_STAT $?
#
#PRINT "Load Schema"
#cd /tmp && unzip -o mysql.zip &>>${LOG} && cd mysql-main && mysql -uroot -p"${MYSQL_PASSWORD}" <shipping.sql &>>${LOG}
#CHECK_STAT $?
#
#
#
