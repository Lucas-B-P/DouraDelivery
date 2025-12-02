FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
RUN ls -la /app/target/
RUN find /app/target -name "*.jar" -type f

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/app.jar app.jar
RUN ls -la /app/
EXPOSE 8080
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV PORT=8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar --server.port=${PORT:-8080}"]

