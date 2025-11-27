FROM maven:3.9-eclipse-temurin-11 AS BUILD-IMAGE


RUN git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr

COPY ./application.properties /sourcecodeseniorwr/src/main/resources/application.properties

RUN cd sourcecodeseniorwr && mvn clean install


FROM tomcat:9.0.112-jdk11

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=BUILD-IMAGE /sourcecodeseniorwr/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]