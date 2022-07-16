CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo -e "\e[31myou have to run the script as a root user or run the script with sudo\e[0m"
      exit 1
  fi
}