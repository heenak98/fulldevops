# Use OpenJDK as the base image
FROM openjdk:17
 
# Set working directory
WORKDIR /app
 
# Copy the built JAR from Jenkins or local build
COPY demo-app/target/*.jar app.jar
 
# Command to run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]