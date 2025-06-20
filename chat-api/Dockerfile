# Build stage
FROM gradle:8.4-jdk17 AS build
WORKDIR /app
COPY build.gradle .
COPY gradle gradle
COPY gradlew .
COPY gradlew.bat .
COPY src src
RUN chmod +x gradlew
RUN ./gradlew build -x test

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"] 