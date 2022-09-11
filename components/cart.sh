source components/common.sh

CHECK_ROOT

PRINT "configure yum repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Install nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "add application user"
useradd roboshop &>>${LOG}
CHECK_STAT $?

PRINT "Download cart content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

PRINT "Remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extract cart content"
unzip /tmp/cart.zip  &>>${LOG}
CHECK_STAT $?


mv cart-main cart
cd /home/roboshop/cart

PRINT "Install Nodejs dependencies"
npm install  &>>${LOG}
CHECK_STAT $?

PRINT "Update systemd configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?


mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service
systemctl daemon-reload  &>>${LOG}
systemctl enable cart  &>>${LOG}

PRINT "Start cart service"
systemctl restart cart &>>${LOG}
CHECK_STAT $?
