#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User already exist $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating /app directorary"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading Shipping service"

cd /app

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping Shipping file"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming jar file"

cp /home/centos/roboshop.shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reloaded"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "Enabling Shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing Mysql"

mysql -h mysql.sm8.tech -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE

VALIDATE $? "Loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting Shipping"
