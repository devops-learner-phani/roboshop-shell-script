source components/common.sh

CHECK_ROOT

PRINT "setting up nodejs "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Installing the nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Creating application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
fi
CHECK_STAT $?

PRINT "Downloading cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

PRINT "Remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?


mv cart-main cart
cd cart

PRINT "Install nodejs dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update systemd file configuration"
sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' /home/roboshop/cart/systemd.service
CHECK_STAT $?

PRINT "Setup systemd configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload
systemctl start cart

PRINT "Start cart service"
systemctl enable cart &>>${LOG}
CHECK_STAT $?