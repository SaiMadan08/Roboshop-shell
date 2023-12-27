#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.sm8.tech

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User already exist $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment"

cd /app

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping payment file"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reloading"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling Payment service"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting Payment service"