source components/common.sh

CHECK_ROOT

PRINT "Configure yum repos"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install REDIS"
yum install redis-6.2.7 -y &>>${LOG}
CHECK_STAT $?

PRINT "Update redis listening address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${LOG}
CHECK_STAT $?

PRINT "Start redis"
systemctl enable redis &>>${LOG} && systemctl restart redis &>>${LOG}
CHECK_STAT $?
