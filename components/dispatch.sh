CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo you are Non root user
      echo You can run this script as a root user or with sudo
      exit 1

  fi
}

CHECK_ROOT

yum install golang -y
useradd roboshop
curl -s -L -o /tmp/dispatch.zip https://github.com/roboshop-devops-project/dispatch/archive/main.zip
cd /home/roboshop
rm -rf dispatch
unzip /tmp/dispatch.zip
mv dispatch-main dispatch
cd dispatch
go mod init dispatch
go get
go build
sed -i -e 's/RABBITMQ-IP/rabbitmq-1.roboshop.internal/' /home/roboshop/dispatch/systemd.service
mv /home/roboshop/dispatch/systemd.service /etc/systemd/system/dispatch.service
systemctl daemon-reload
systemctl enable dispatch
systemctl restart dispatch


