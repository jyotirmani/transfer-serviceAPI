FROM adoptopenjdk/openjdk8:x86_64-alpine-jdk-1.8.0_162

ENV PRJDIR /usr/src/dev

COPY ./pom.xml $PRJDIR/pom.xml
COPY ./.mvn $PRJDIR/.mvn

WORKDIR $PRJDIR

RUN ./mvn dependency:go-offline -B

COPY ./src $PRJDIR/src

RUN ./mvn clean verify

EXPOSE 7000

ENTRYPOINT ["java", "-jar", "./target/transfer-service-1.0.jar"]