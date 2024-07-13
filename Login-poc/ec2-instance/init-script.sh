#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define environment variables
GIT_REPO_URL="https://github.com/meghanakoturi/TERRAFORM-POC.git"
PROJECT_DIR="/home/ec2-user/project"
MYSQL_ROOT_PASSWORD="Apple@3005"
MYSQL_DATABASE="loginapp"
MYSQL_USER="db_user"
MYSQL_PASSWORD="Sujatha@3005"

# Update and install necessary packages
echo "Updating and installing packages..."
sudo yum update -y
sudo yum install -y cloud-init
sudo systemctl enable cloud-init
sudo systemctl start cloud-init


# Install additional packages
sudo yum install -y docker git java-17* maven

# Start Docker service and enable it on boot
echo "Starting Docker service..."
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo systemctl enable docker

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a directory for the project
echo "Setting up project directory..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clone the Git repository
echo "Cloning Git repository..."
git clone $GIT_REPO_URL .

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Print the public IP address
echo "The instance public IP is: $INSTANCE_PUBLIC_IP"



# Modify application properties to update the IP address in the JDBC URL
echo "Updating JDBC URL in verification.jsp..."

sed -i "s|jdbc:mysql://[0-9.]*:3306|jdbc:mysql://$INSTANCE_PUBLIC_IP:3306|" src/main/webapp/verification.jsp

# Build the project using Maven
echo "Building the project with Maven..."
sudo mvn clean package

# Create docker-compose.yml file
echo "Creating docker-compose.yml..."
cat << EOF > docker-compose.yml
version: '3.8'

services:
  tomcat:
    build:
      context: .
      dockerfile: Dockerfile.tomcat
    ports:
      - "8080:8080"
    volumes:
      - ./target/Login.war:/usr/local/tomcat/webapps/ROOT.war

  mysql:
    build:
      context: .
      dockerfile: Dockerfile.mysql
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      MYSQL_DATABASE: $MYSQL_DATABASE
      MYSQL_USER: $MYSQL_USER
      MYSQL_PASSWORD: $MYSQL_PASSWORD
    ports:
      - "3306:3306"
    volumes:
      - ./data.sql:/docker-entrypoint-initdb.d/data.sql

  redis:
    image: redis:latest
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  redis-data:
    driver: local
EOF

# Change ownership of the project directory
echo "Changing ownership of the project directory..."
sudo chown -R ec2-user:ec2-user $PROJECT_DIR

# Start Docker Compose
echo "Starting Docker Compose..."
cd $PROJECT_DIR
docker-compose up -d

echo "Setup completed successfully!"
