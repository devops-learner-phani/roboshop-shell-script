CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo -e "\e[31myou have to run the script as a root user or run the script with sudo\e[0m"
      exit 1
  fi
}

CHECK_STAT() {
echo "--------------" >>${LOG}
if [ $1 -ne 0 ]; then
  echo -e "\e[31mFAILURE\e[0m"
  echo -e "\n check log file - ${LOG} for error\n"
  exit 2
else
  echo -e "\e[32mSUCCESS\e[0m"
fi
}

LOG=/tmp/roboshop.log
rm -r ${LOG}

PRINT() {
  echo "------ $1 ------" >>${LOG}
  echo "$1"
}


APP_COMMON_SETUP() {

    PRINT "Creating application user"
     id roboshop &>>${LOG}
     if [ $? -ne 0 ]; then
       useradd roboshop &>>${LOG}
     fi
    CHECK_STAT $?

    PRINT "Downloading ${COMPONENT} content"
    curl -s -L -o /tmp/${COMPONENT}.zip https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip &>>${LOG} && cd /home/roboshop
    CHECK_STAT $?

    PRINT "Remove old content"
    rm -rf ${COMPONENT} &>>${LOG}
    CHECK_STAT $?

    PRINT "Extract ${COMPONENT} content"
    unzip /tmp/${COMPONENT}.zip &>>${LOG}  && mv ${COMPONENT}-main ${COMPONENT} && cd ${COMPONENT}
    CHECK_STAT $?



}

SYSTEMD() {
    PRINT "Update system congifuration"
    sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
    CHECK_STAT $?

    PRINT "Setup system configuration"
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
    CHECK_STAT $?


    PRINT "restart ${COMPONENT} service"
    systemctl enable ${COMPONENT} &>>${LOG} && systemctl restart ${COMPONENT} &>>${LOG}
    CHECK_STAT $?
}

NODEJS() {

  CHECK_ROOT

  PRINT "setting up nodejs "
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Installing the nodejs"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Install nodejs dependencies"
  npm install &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}


NGINX() {
  CHECK_ROOT

  PRINT "Install nginx "
  yum install nginx -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Start Nginx service"
  systemctl start nginx &>>${LOG} && systemctl enable nginx &>>${LOG}
  CHECK_STAT $?


  PRINT "Download frontend content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
  CHECK_STAT $?

  PRINT "remove old content"
  cd /usr/share/nginx/html 
  rm -rf * &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} content"
  unzip /tmp/${COMPONENT}.zip &>>${LOG}
  CHECK_STAT $?

  PRINT "Organise ${COMPONENT} content"
  mv ${COMPONENT}-main/static/* . &>>${LOG}
  CHECK_STAT $?

  PRINT "Setup system configuration"
  mv ${COMPONENT}-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
  CHECK_STAT $?

  for backend in catalogue user cart shipping payment ; do
  PRINT "Update $backend configuration"
  sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' -e '/user/ s/localhost/user.roboshop.internal/' -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
  CHECK_STAT $?
  done

  PRINT "Restart nginx service"
  systemctl enable nginx &>>${LOG} && systemctl restart nginx &>>${LOG}
  CHECK_STAT $?

}

MAVEN() {

  CHECK_ROOT
  
  PRINT "Install maven "
  yum install maven -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Compile ${COMPONENT} code"
  mvn clean package &>>${LOG}  && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG}
  CHECK_STAT $?

  SYSTEMD

}

PYTHON() {

  CHECK_ROOT

  PRINT "Install Python-3"
  yum install python36 gcc python3-devel -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Download Python dependencies"
  pip3 install -r requirements.txt &>>${LOG}
  CHECK_STAT $?

  USER_ID=$(id -u roboshop)
  GROUP_ID=$(id -g roboshop)

  PRINT "Update ${COMPONENT} configuration"
  sed -i -e "/^uid/ c uid = ${USER_ID}" -e "/^gid/ c gid = ${GROUP_ID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>${LOG}
  CHECK_STAT $?

  SYSTEMD 

}

GOLANG() {
  CHECK_ROOT

  PRINT "Install golang services"
  yum install golang -y  &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Installing dependencies"
  go mod init dispatch  &>>${LOG} && go get  &>>${LOG} && go build  &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}