curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
yum install mysql-community-server -y
systemctl start mysqld
systemctl enable mysqld
MYSQL_DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" >/tmp/mysql
 mysql -uroot -p"${MYSQL_PASSWORD}" </tmp/mysql
#grep temp /var/log/mysqld.log
#mysql_secure_installation
#mysql -uroot -pRoboShop@1

#curl -s -L -o /tmp/mysql.zip https://github.com/roboshop-devops-project/mysql/archive/main.zip
#cd /tmp
#unzip mysql.zip

# cd /tmp
# unzip mysql.zip
# cd mysql-main
# mysql -u root -pRoboShop@1 <shipping.sql

