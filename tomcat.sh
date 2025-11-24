#!/bin/bash

# --- Configuration for Older Versions ---
# Tomcat 9.0.80 (Stable version for Java 11)
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz"

# Maven 3.8.8 (Compatible older version)
MAVEN_VERSION="3.8.8"

# Java 11 (OpenJDK)
dnf -y install java-11-openjdk java-11-openjdk-devel
dnf install git wget unzip zip -y

# --- Tomcat Download and Setup ---
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
# The tar output will now contain apache-tomcat-9.0.80/
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
useradd --shell /sbin/nologin tomcat
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

# NOTE: JAVA_HOME for Java 11 on CentOS/RHEL is typically /usr/lib/jvm/jre-11-openjdk
Environment=JAVA_HOME=/usr/lib/jvm/jre-11-openjdk

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
export MAVEN_OPTS="-Xmx512m"

# --- VProfile Deployment ---
git clone -b Master https://github.com/abdelrahmanonline4/sourcecodeseniorwr
cd sourcecodeseniorwr
/usr/local/maven$MAVEN_VERSION/bin/mvn install
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 20
systemctl stop firewalld
systemctl disable firewalld
cp /vagrant/application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat