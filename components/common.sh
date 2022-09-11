CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
    echo -e "\e[31m Need to run the script as root user or add sudo\e[0m"
    exit 1
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

#CHECK_STAT() {
#  if [ $? -ne 0 ]; then
#    echo -e "\e[31m FAILED \e[0m"
#  else
#    echo -e "\e[32m SUCCESS \e[0m"
#  fi
#}