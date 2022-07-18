source components/common.sh

CHECK_ROOT

echo "setting up nodejs "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

echo "Installing the nodejs" 
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

echo "Creating application user"
useradd roboshop &>>${LOG}
CHECK_STAT $?

echo "Downloading cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

echo "Remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

echo "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?


mv cart-main cart
cd cart

echo "Install nodejs dependencies"
npm install &>>${LOG}
CHECK_STAT $?

echo "Update systemd file configuration"
sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' /home/roboshop/cart/systemd.service
CHECK_STAT $?

echo "Setup systemd configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload
systemctl start cart

echo "Start cart service"
systemctl enable cart &>>${LOG}
CHECK_STAT $?