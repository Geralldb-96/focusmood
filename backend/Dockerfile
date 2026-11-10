FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app
RUN useradd --system --no-create-home focusmood
COPY --from=build /app/target/focusmood-backend-*.jar app.jar
USER focusmood
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
