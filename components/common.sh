CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
    echo -e "\e[31m Need to run the script as root user or add sudo\e[0m"
    exit 1
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

CHECK_STAT() {
  echo "----------------------"  >>${LOG}
  if [ $? -ne 0 ]; then
    echo -e "\e[31m FAILED \e[0m"
  else
    echo -e "\e[32m SUCCESS \e[0m"
  fi
}

PRINT() {
  echo "----------$1----------"  >>${LOG}
  echo "$1"
}

APP_COMMON_SETUP() {

  PRINT "add application user"
  useradd roboshop &>>${LOG}
  CHECK_STAT $?

  PRINT "Download ${COMPONENT} content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
  CHECK_STAT $?

  PRINT "Remove old content"
  cd /home/roboshop && rm -rf ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} content"
  unzip /tmp/${COMPONENT}.zip  &>>${LOG}  && mv ${COMPONENT}.zip-main ${COMPONENT}.zip && cd /home/roboshop/${COMPONENT}.zip
  CHECK_STAT $?

}

SYSTEMD() {

  PRINT "Update systemd configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/${COMPONENT}.zip/systemd.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Organise content"
  mv /home/roboshop/${COMPONENT}.zip/systemd.service /etc/systemd/system/${COMPONENT}.zip.service &>>${LOG} &&  systemctl daemon-reload  &>>${LOG}
  CHECK_STAT $?


  PRINT "Start ${COMPONENT} service"
  systemctl enable ${COMPONENT}.zip  &>>${LOG} && systemctl restart ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

}


NODEJS() {

  CHECK_ROOT

  PRINT "configure yum repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Install nodejs"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

   APP_COMMON_SETUP

  PRINT "Install Nodejs dependencies"
  npm install  &>>${LOG}
  CHECK_STAT $?

  SYSTEMD

}