source components/common.sh

CHECK_ROOT

PRINT "Configure yum repos"
curl -s -o /etc/yum.repos.d/redis.repo https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install redis"
yum install redis-6.2.7 -y &>>${LOG}
CHECK_STAT $?

PRINT "Configure redis service"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${LOG}
CHECK_STAT $?

PRINT "restart redis server"
systemctl enable redis &>>${LOG} && systemctl restart redis &>>${LOG}
CHECK_STAT $?