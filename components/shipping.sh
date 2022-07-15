yum install maven -y
useradd roboshop
curl -s -L -o /tmp/shipping.zip https://github.com/roboshop-devops-project/shipping/archive/main.zip
cd /home/roboshop
rm -rf shipping
unzip /tmp/shipping.zip
mv shipping-main shipping
cd shipping
mvn clean package
mv target/shipping-1.0.jar shipping.jar
sed -i -e 's/CARTENDPOINT/cart-1.roboshop.internal/' -e 's/DBHOST/mysql-1.roboshop.internal/' /home/roboshop/shipping/systemd.service
mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
systemctl daemon-reload
systemctl enable shipping
systemctl start shipping


