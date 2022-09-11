source components/common.sh

CHECK_ROOT

if [ -z "${RABBITMQ_USER_PASSWORD}" ]; then
  echo "Needed RABBITMQ_USER_PASSWORD variable"
  exit 1
fi

PRINT "Configure yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
CHECK_STAT $?

PRINT "Install ERLANG & RABBITMQ"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG}
CHECK_STAT $?

PRINT "Start rabbitmq service"
systemctl enable rabbitmq-server &>>${LOG} && systemctl start rabbitmq-server &>>${LOG}
CHECK_STAT $?

rabbitmqctl list_users | grep roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  PRINT "Add roboshop user"
  rabbitmqctl add_user roboshop ${RABBITMQ_USER_PASSWORD} &>>${LOG}
  CHECK_STAT $?
fi

PRINT "Give permissions and tags"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
CHECK_STAT $?
