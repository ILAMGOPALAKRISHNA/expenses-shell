#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter DB password:"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2... $G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "please run this script with root access."
    exit 1 #manually exit if error comes.
else
    echo "you are super user."
fi 

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Install mysql server"

systemctl enable mysqld  &>>$LOGFILE
VALIDATE $? "Enabling  mysql server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting  mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "setting up root password"

# below code will be useful for idempotent nature

mysql -h db.ilam-78s.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
     mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
     VALIDATE $? "MYSQL root password set up"
else
     echo -e "root password is already setup...$Y SKIPPING $N"
fi

