# Build stage
FROM gradle:8.4-jdk17 AS build
WORKDIR /app
COPY build.gradle .
COPY src src
RUN gradle build -x test

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"] 