FROM maven:3.9.9-amazoncorretto-21 as build
WORKDIR /app
COPY . .

# build the application into a single JAR, including dependencies
RUN mvn --batch-mode package && \
    mv target/*.jar app.jar

FROM amazoncorretto:21.0.5-alpine3.19
ENV PORT=8888
USER root

WORKDIR /app
COPY --from=build /app/app.jar ./

CMD java -jar app.jar --server.port=$PORT