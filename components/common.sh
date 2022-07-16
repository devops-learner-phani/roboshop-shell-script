CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo -e "\e[31myou have to run the script as a root user or run the script with sudo\e[0m"
      exit 1
  fi
}

CHECK_STAT() {
if [ $1 -ne 0 ]; then
  echo -e "\e[31mFailure\e[0m"
  exit 2
else
  echo -e "\e[32mSuccess\e[0m"
fi
}

LOG=/tmp/roboshop.log
rm -r $LOG