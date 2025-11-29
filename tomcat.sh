#!/bin/bash

# --- Configuration for Older Versions ---
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz"
MAVEN_VERSION="3.8.8"

#  CHANGE 1: Use apt for package installation
apt update -y
apt install openjdk-11-jdk git wget unzip zip -y

# --- Tomcat Download and Setup ---
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
#  CHANGE 2: Use /bin/false for nologin on Ubuntu/Debian
useradd --shell /bin/false tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat

# --- Systemd Service File ---
rm -rf /etc/systemd/system/tomcat.service

cat <<EOT > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]

User=tomcat
Group=tomcat

WorkingDirectory=/usr/local/tomcat

#  CHANGE 3: JAVA_HOME path for Ubuntu/Debian systems
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh


RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

EOT

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# --- Maven Download and Setup ---
cd /tmp/
wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip
unzip apache-maven-$MAVEN_VERSION-bin.zip
cp -r apache-maven-$MAVEN_VERSION /usr/local/maven$MAVEN_VERSION
#  FIX: Set JAVA_HOME dynamically for the current shell so mvn works
JAVA_PATH=$(dirname $(dirname $(readlink -f /usr/bin/java)))
export JAVA_HOME=$JAVA_PATH
export PATH=$JAVA_HOME/bin:$PATH
export MAVEN_OPTS="-Xmx512m"

# --- VProfile Deployment ---
git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr
cd sourcecodeseniorwr

#  NOTE: The application.properties content is copied directly into the source code directory.
cat <<EOT > src/main/resources/application.properties
#JDBC Configutation for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://database-1.cd4eqmkwmwz6.ap-northeast-1.rds.amazonaws.com:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin123

#Memcached Configuration For Active and StandBy Host
#For Active Host
memcached.active.host=vapp-cached-2lld2l.serverless.apne1.cache.amazonaws.com
memcached.active.port=11211
#For StandBy Host
memcached.standBy.host=vapp-cached-2lld2l.serverless.apne1.cache.amazonaws.com
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=amqps://b-a947ebe4-610f-497f-9799-7426f0cdf2b8.mq.ap-northeast-1.on.aws
rabbitmq.port=5671
rabbitmq.username=rabbit
rabbitmq.password=rabbitrabbit

#Elasticesearch Configuration
elasticsearch.host =vprosearch01
elasticsearch.port =9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode

EOT

/usr/local/maven$MAVEN_VERSION/bin/mvn install
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 20
systemctl restart tomcat