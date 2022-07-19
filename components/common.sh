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

NODEJS() {

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

  PRINT "Downloading ${COMPONENT} content"
  curl -s -L -o /tmp/${COMPONENT}.zip https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip &>>${LOG}
  CHECK_STAT $?

  cd /home/roboshop

  PRINT "Remove old content"
  rm -rf ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} content"
  unzip /tmp/${COMPONENT}.zip &>>${LOG}
  CHECK_STAT $?


  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install nodejs dependencies"
  npm install &>>${LOG}
  CHECK_STAT $?

  PRINT "Update systemd file configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
  CHECK_STAT $?

  PRINT "Setup systemd configuration"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG}
  CHECK_STAT $?

  systemctl daemon-reload
  systemctl start ${COMPONENT}

  PRINT "Start ${COMPONENT} service"
  systemctl enable ${COMPONENT} &>>${LOG}
  CHECK_STAT $?
}