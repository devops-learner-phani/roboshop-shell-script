source components/common.sh

CHECK_ROOT

PRINT "Configure yum repos"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install mongodb"
yum install mongodb-org -y &>>${LOG}
CHECK_STAT $?

PRINT "Configure Mongodb service"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
CHECK_STAT $?

PRINT "Restart mongodb service"
systemctl restart mongod &>>${LOG} && systemctl enable mongod &>>${LOG}
CHECK_STAT $?

PRINT "Download Schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG}
CHECK_STAT $?

PRINT "Load Schema"
cd /tmp && unzip -o mongodb.zip &>>${LOG} && cd mongodb-main && mongo < catalogue.js &>>${LOG} && mongo < users.js &>>${LOG}
CHECK_STAT $?


