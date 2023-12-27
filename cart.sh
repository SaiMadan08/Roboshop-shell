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
        echo -e "$2 ... $R Failed $N"
        exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R You are not root user, run with root user access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "Creating roboshop user"
else
    echo -e "User already exist $Y Skipping $N"
fi

mkdir /app

VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading Cart application"

cd /app 

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping cart application"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying Cart service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Cart daemon reload"

systemctl enable cart  &>> $LOGFILE

VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart"

