# ─────────────────────────────────────────
# STAGE 1: Build WAR using Maven
# ─────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first (Docker cache trick)
# If pom.xml hasn't changed, Maven won't re-download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Now copy source and build
COPY src ./src

RUN mvn clean package -DskipTests=true

# ─────────────────────────────────────────
# STAGE 2: Run WAR on Tomcat
# ─────────────────────────────────────────
FROM tomcat:10.1-jdk17-temurin-jammy

# Remove default Tomcat sample apps (saves space + security)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR from Stage 1 into Tomcat
# Naming it ROOT.war = accessible at "/" not "/EZEV-1.0-SNAPSHOT"
COPY --from=builder /app/target/EZEV-1.0-SNAPSHOT.war \
     /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat's default port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
