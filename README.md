# Deploying a Web Application with MySQL, Tomcat, and Redis using Terraform and Docker on AWS EC2

# Introduction :

This documentation provides a comprehensive guide to deploying a web application using Terraform to provision infrastructure on AWS, and Docker to manage application services. The application, a login proof-of-concept (LOGIN-POC), consists of a Java-based web application running on Tomcat, with MySQL as the database and Redis for caching. The deployment process is automated using a combination of Terraform scripts and Docker Compose, ensuring a consistent and repeatable setup. By following this guide, you will learn how to:

1. Set up the necessary AWS infrastructure using Terraform.
2. Configure an EC2 instance to host the application.
3. Deploy the application using Docker containers.
4. Manage dependencies and environment variables effectively.
5. Ensure secure access and proper configuration of the services.
   
The guide is intended for developers and DevOps engineers looking to streamline their deployment process and leverage infrastructure as code (IaC) practices for better management and scalability of their applications.

# Technologies Used :
- AWS EC2: Amazon Elastic Compute Cloud (EC2) is used to provision and manage virtual servers in the cloud. EC2 instances provide scalable computing capacity, allowing you to deploy and run applications with ease.
- Terraform: An open-source infrastructure as code software tool that enables you to define and provision data center infrastructure using a high-level configuration language. Terraform is used to automate the creation of AWS resources like VPC, subnets, security groups, and EC2 instances.
- Docker: Docker is a platform for developing, shipping, and running applications inside containers. Containers are lightweight and portable, ensuring that the application runs consistently across different environments.
- Docker Compose: A tool for defining and running multi-container Docker applications. It allows you to use a YAML file to configure the application’s services and then create and start all the services with a single command.
- Tomcat: An open-source implementation of the Java Servlet, JavaServer Pages (JSP), Java Expression Language, and Java WebSocket technologies. Tomcat is used to deploy and serve the Java-based web application.
- Java: The primary programming language used in this project for developing the web application. Java is a versatile and widely-used language, particularly well-suited for building server-side applications.
- JSP (JavaServer Pages): A technology used to create dynamic web content by embedding Java code in HTML pages. JSP files in this project are used to handle user interactions and generate dynamic content based on the application logic.
- MySQL: A popular open-source relational database management system. MySQL is used to store and manage the application's data.
- Redis: An open-source in-memory data structure store, used as a database, cache, and message broker. Redis is used to cache frequently accessed data to improve application performance.
- Maven: A build automation tool used primarily for Java projects. Maven is used to manage project dependencies and build the Java application.
- Git: A version control system used to track changes in the source code during software development. Git is used to manage and clone the project repository.

# Prerequisites :
Ensure you have the following installed and configured on your local machine:

* Terraform: Install Terraform on your local machine. You can download it from Terraform's official website.
* AWS CLI configured with appropriate credentials.
* A public/private key pair for SSH access to the EC2 instance

# Project Structure of terraform :

LOGIN-POC/
- ├── ec2-instance/
- │----------└── init-script.sh
- ├── main.tf
- ├── variables.tf
- ├── outputs.tf
- └── keypair.pem

1. main.tf :
   
main.tf is a Terraform configuration file that defines various AWS resources needed to set up the infrastructure for your project. Below is a detailed explanation of the components and their purposes:

- Provider: Specifies that Terraform will manage AWS resources. The region is set to "us-east-1" (you can change this to your preferred region).
- VPC: Creates a Virtual Private Cloud with a CIDR block of "10.0.0.0/16". This is your isolated network in the cloud.
- Subnet: Defines a subnet within the VPC with a CIDR block of "10.0.1.0/24". The subnet is placed in the specified availability zone.
- Internet Gateway: Provides internet access to the VPC. It allows resources in the VPC to connect to the internet.
- Route Table: Directs internet traffic from the subnet to the internet gateway.
- Route Table Association: Associates the route table with the subnet to enable internet access for instances in the subnet.
- Security Group: Controls the inbound and outbound traffic for your instances. The rules defined:
   1. Allow SSH access (port 22) from anywhere.
   2. Allow HTTP access (port 8080) from anywhere.
   3. Allow MySQL access (port 3306) from anywhere.
   4. Allow Redis access (port 6379) from anywhere.
   5. Allow all outbound traffic.
- EC2 Instance: Provisions an EC2 instance with the following attributes:
   1. AMI: Amazon Machine Image to use (update with your desired AMI ID).
   2. Instance Type: Specifies the instance size (e.g., t3.medium).
   3. Key Name: Name of the SSH key pair for accessing the instance.
   4. Subnet: Associates the instance with the defined subnet.
   5. Security Group: Attaches the defined security group to the instance.
   6. Public IP: Associates a public IP address with the instance.
   7. User Data: Runs the init-script.sh during instance initialization to set up the environment.
   8 Tags: Adds a tag to name the instance "docker-host".

This main.tf configuration file sets up a VPC with a subnet, internet gateway, route table, security group, and an EC2 instance configured to run Docker and host your application.

2. variables.tf :

variables.tf is a Terraform configuration file that defines variables used in the Terraform setup. These variables make the configuration more flexible and reusable by allowing you to specify values that can be easily changed without modifying the main configuration files. Below is a detailed explanation of the variables defined:

- git_repo_url: Specifies the URL of the Git repository that contains the project code. This variable allows you to change the repository URL without modifying the script directly. The default value is set to
```
 https://github.com/meghanakoturi/TERRAFORM-POC.git
```
- public_key_path: Specifies the path to your SSH public key file. This key is used to securely access the EC2 instance. The default value is set to the typical location of an SSH public key file, "~/.ssh/id_rsa.pub".
- instance_type: Defines the type of EC2 instance to be created. The default value is set to "t3.medium". You can change this to any other EC2 instance type based on your performance and cost requirements.

- Usage of Variables:

These variables are referenced in the main.tf file and other configuration files to make the Terraform setup more dynamic and adaptable.This approach allows you to quickly update the configuration by changing the variable values in variables.tf without having to modify the actual resource definitions.

3. outputs.tf :

outputs.tf is a Terraform configuration file that defines the output values of the Terraform setup. Outputs are used to display information about the resources created by the Terraform configuration. They are helpful for easily accessing and referencing important information, such as IP addresses or resource IDs, after the infrastructure has been provisioned.

Below is a detailed explanation of the output values defined:
- instance_public_ip: This output provides the public IP address of the EC2 instance created by the Terraform configuration.
   1. description: Provides a human-readable description of what this output represents.
   2. value: Specifies the actual value to be output, which is the public IP address of the EC2 instance (aws_instance.docker_host.public_ip). This value is dynamically retrieved from the created EC2 instance.
- instance_id: This output provides the ID of the EC2 instance created by the Terraform configuration.
   1. description: Provides a human-readable description of what this output represents.
   2. value: Specifies the actual value to be output, which is the ID of the EC2 instance (aws_instance.docker_host.id). This value is dynamically retrieved from the created EC2 instance.

- Purpose of Outputs :

These outputs are useful for referencing key details of the infrastructure. For example:

1. instance_public_ip can be used to connect to the EC2 instance via SSH or to access services running on it.
2. instance_id can be used to manage or reference the specific EC2 instance within AWS.
By defining these outputs, you can easily access important information about your infrastructure without manually looking up details in the AWS Management Console. This is especially useful for automating deployment processes or integrating with other tools.

4. init-script.sh :

init-script.sh is a shell script used to initialize the EC2 instance. It installs necessary packages, configures services, clones the Git repository, and sets up Docker and Docker Compose to run the application. Below is a detailed explanation of each section of the script:
- #!/bin/bash: Specifies that the script should be run using the Bash shell.
- set -e: Ensures the script exits immediately if any command fails, which helps to catch errors early.
- Environment Variables: Define important variables used throughout the script, such as the Git repository URL, project directory, and MySQL credentials.
- Update and Install Packages: Updates the package list and installs cloud-init. It also enables and starts the cloud-init service.
- Install Additional Packages: Installs Docker, Git, Java 17, and Maven, which are required for the project.
- Start Docker Service: Starts the Docker service, adds the ec2-user to the Docker group, and enables Docker to start on boot.
- Install Docker Compose: Downloads the latest version of Docker Compose and makes it executable.
- Setup Project Directory and Clone Repository: Creates the project directory and clones the Git repository into it.
- Retrieve Public IP: Retrieves the public IP address of the EC2 instance using AWS metadata service.
- Update JDBC URL: Updates the JDBC URL in verification.jsp to use the instance's public IP address.
- Build Project: Uses Maven to build the project and create the WAR file
- Create Docker Compose File: Dynamically creates a docker-compose.yml file to define the services (Tomcat, MySQL, and Redis) and their configurations.
- Set Permissions and Start Services: Changes ownership of the project directory to the ec2-user and starts the services defined in docker-compose.yml in detached mode.

This script automates the setup process, ensuring that the EC2 instance is correctly configured to run the application with minimal manual intervention.

# Project Directory Structure :
project
- |____ src
- |---------|____ main
- |------------------|____ resources
- |--------------------------------|____ CacheService.java
- |--------------------------------|____ RedisConfig.java
- |------------------|____ webapp
- |-----------------------------|____ WEB-INF
- |-----------------------------------------|____ web.xml
- |-----------------------------|____ dashboard.jsp
- |-----------------------------|____ dashboard2.jsp
- |-----------------------------|____ index.jsp
- |-----------------------------|____ verification.jsp
- |____ Dockerfile.mysql
- |____ Dockerfile.tomcat
- |____ data.sql
- |____ pom.xml

Git repository
```
  https://github.com/meghanakoturi/TERRAFORM-POC.git
```
1. src/main/resources :
- CacheService.java:
   1. Purpose: Provides caching functionality to improve performance by storing frequently accessed data in memory. This can reduce the need to repeatedly access a database or other slower storage.
   2. Details: This class likely contains methods for setting, getting, and invalidating cache entries. It might use Redis, a popular in-memory data structure store, to manage the cache.
- RedisConfig.java:
   1. Purpose: Configures the connection and settings for Redis, which is used as the caching layer.
   2. This file typically includes configuration settings such as the Redis server address, port, and any authentication credentials. It might also define the settings for connection pooling and timeouts.

2. src/main/webapp/WEB-INF/ :This directory is a standard part of a Java web application structure. It contains web application resources such as JSP (JavaServer Pages) files, which are used to build dynamic web pages. 
- dashboard.jsp:
    1. Purpose: Serves as the main dashboard page of the application.
    2. This page likely provides an overview or summary of key information and functionalities available to the user after logging in. It might include charts, tables, or links to other parts of the application.
- dashboard2.jsp:
    1. Purpose: An alternative or additional dashboard page.
    2. Details: This page could offer different views or additional information not present in the main dashboard. It might cater to a different type of user or provide supplementary functionalities.
- index.jsp:
    1. Purpose: The landing page or homepage of the application.
    2. Details: This page is usually the first page that users see when they visit the web application. It might include a welcome message, links to login or register, and other introductory content.
-  verification.jsp:
    1. Purpose: Handles user verification or confirmation.
    2. Details: This page is likely involved in verifying user actions, such as email verification, password reset confirmations, or other security-related processes.

3. Dockerfile.mysql :
- FROM mysql:8.0: This line specifies that this Dockerfile uses the official MySQL Docker image version 8.0 as the base image.
- ENV ...: Sets environment variables for MySQL:
  1. MYSQL_ROOT_PASSWORD: Sets the root password for MySQL.
  2. MYSQL_DATABASE: Specifies the name of the MySQL database to be created.
  3. MYSQL_USER: Defines a MySQL user.
  4. MYSQL_PASSWORD: Sets the password for the MySQL user defined above.
- COPY data.sql /docker-entrypoint-initdb.d/: Copies the data.sql file from the local directory (in the Docker build context) into the Docker image at /docker-entrypoint-initdb.d/. This directory is where MySQL Docker images automatically execute .sql scripts during initialization.
- RUN echo ...: Runs commands inside the Docker image:
   1. Creates a SQL script grant-permissions.sql in the /docker-entrypoint-initdb.d/ directory.
   2.This script creates the specified database (loginapp) if it doesn't exist and grants all privileges on that database to the MySQL user (db_user).
- EXPOSE 3306: Informs Docker that the container listens on port 3306 at runtime. It doesn't actually publish the port. It's a convention used for documentation purposes.

This Dockerfile sets up a MySQL database inside a Docker container, initializes it with a specified schema (data.sql), and grants necessary privileges to a user (db_user). It's typically used with Docker Compose or directly with docker build and docker run commands to deploy and manage MySQL instances in a containerized environment.

4. Dockerfile.tomcat :
- FROM tomcat:9.0: This line specifies that this Docker image is based on the official Tomcat image version 9.0 from Docker Hub. Tomcat is a popular web server and servlet container for running Java web applications.
- RUN apt-get update && apt-get install -y openjdk-17-jdk: This command updates the package list inside the Docker image and installs OpenJDK 17. Java is required to run Java-based applications, including those deployed on Tomcat.
- ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64: Sets the JAVA_HOME environment variable to point to the Java 17 installation directory. This environment variable is used by Java applications to locate the Java runtime environment.
- EXPOSE 8080: Informs Docker that the container listens on port 8080 at runtime. This is the default port used by Tomcat for serving web applications.
- COPY target/Login.war /usr/local/tomcat/webapps/ROOT.war: Copies the WAR (Web Application Archive) file named Login.war from the target directory of your local project into the /usr/local/tomcat/webapps directory inside the Docker container. Tomcat automatically deploys applications placed in this directory.

This Dockerfile is essential for building a Docker image that can run your Java web application (Login.war) on Tomcat within a Docker container.

5. data.sql :
- CREATE TABLE: Defines SQL statements to create two tables, login and user. Each table has columns for id, username, and password. The id column is set to auto-increment for generating unique identifiers.
- INSERT INTO: Inserts initial data into the login and user tables. For example, it inserts a user with the username 'meghana' and password 'meghana123' into the login table, and a user with the username 'localhost' and password 'Localhost@123' into the user table.

The data.sql file is typically used in conjunction with Docker and database Dockerfiles to initialize the database schema and populate initial data when the Docker container starts. In your setup, it will be copied into the MySQL Docker container (Dockerfile.mysql) and executed as part of the database initialization process. This ensures that your application has the required database structure and initial data when it starts up in a Docker environment.

6. pom.xml :
- Purpose: The Project Object Model file for Maven, which defines the project structure and dependencies.
- Details: This XML file includes information about the project and configuration details used by Maven to build the project. It specifies dependencies, plugins, and build profiles.

# Terraform Initialization (terraform init):
- Navigate to Project Directory:
Open your terminal or command prompt and change directory (cd) to where your Terraform configuration files (main.tf, variables.tf, outputs.tf and init-script.sh) are located.
- Initialize Terraform:
Run the following command to initialize Terraform and download necessary providers/plugins specified in your configuration files:
```
  terraform init
```

# Terraform Planning (terraform plan):
- Generate Execution Plan:
After initialization, generate a Terraform execution plan to preview the changes that Terraform will make to your infrastructure:
```
   terraform plan
```
Terraform examines all configuration files (main.tf, variables.tf, outputs.tf and init-script.sh) and compares them against the current state to determine what actions are necessary.
- Review Execution Plan:
   1. Review the output of terraform plan to understand:
   2. Resources that will be created, modified, or destroyed.
   3. Any errors or warnings related to configuration.
   4. Estimated changes in terms of resources and dependencies.
      
# Terraform Apply (terraform apply):
- Apply Terraform Configuration:
Once you are satisfied with the execution plan and ready to apply changes, run:
```
   terraform apply
```
Terraform prompts for confirmation (yes) before proceeding with applying changes.
- Monitor Progress:
During execution, Terraform shows real-time progress and status updates as it creates, modifies, or destroys resources.
- Review Outputs:
After successful completion, Terraform outputs any defined outputs (outputs.tf), such as instance IDs or public IP addresses.
- Access Provisioned Infrastructure:
Use the outputs provided by Terraform to access and interact with the provisioned infrastructure, such as accessing an EC2 instance deployed using Terraform.
- Update State:
Terraform updates its state file (.tfstate) with the current state of resources post-execution, which is used for future operations and maintenance.

# Notes :
- State Management: Ensure proper state management (terraform.tfstate files) to track infrastructure changes and maintain consistency across deployments.
- Validation: Always validate and review Terraform plan output (terraform plan) before applying changes (terraform apply) to prevent unintended modifications.
  
# Verification :
- After completion, verify the infrastructure on your cloud provider's console or through command-line tools to ensure resources are provisioned correctly.
  
By following these steps, Terraform automates the process of infrastructure deployment, ensuring consistency and reliability across environments. Always review the execution plan (terraform plan) before applying changes (terraform apply) to prevent unintended modifications to your infrastructure.

# Access and Testing :

- Verification: Access the deployed application via the EC2 instance’s public IP address.
- Ensure the application (Login.war) is accessible at http://<public_ip>:8080/.
- Test functionality and verify database operations against MySQL (jdbc:mysql://<public_ip>:3306/loginapp).

# Testing :
Testing the deployed application involves verifying its functionality, performance, and reliability. Here’s a structured approach to testing your Java web application deployed using Docker containers on AWS EC2:

- Testing Approach
1. Functional Testing
    1. User Interface (UI):
 Login Functionality: Verify user login and authentication process.
 Dashboard: Ensure proper rendering and functionality of dashboard features (dashboard.jsp, dashboard2.jsp).
 Verification Page: Validate user verification flow (verification.jsp).
2. Database Operations
    1. MySQL Integration:
Data Persistence: Confirm CRUD (Create, Read, Update, Delete) operations on login and user tables.
SQL Queries: Test SQL queries executed by the application.
3. Performance Testing
    1. Load Testing:
       Simulate Concurrent Users: Use tools like Apache JMeter to simulate multiple concurrent users accessing the application.
Monitor Response Times: Measure response times under different load conditions to ensure acceptable performance.
4. Security Testing
   1. Vulnerability Scanning: Conduct security scans to identify and mitigate potential vulnerabilities.
   2. Access Controls: Validate access controls to ensure sensitive data and functionalities are appropriately protected.
5. Compatibility Testing
   1. Browser Compatibility: Test the application across different web browsers (e.g., Chrome, Firefox, Safari) to ensure consistent behavior.
   2. Device Compatibility: Check responsiveness and functionality on different devices (e.g., desktops, tablets, mobile phones).
6. Integration Testing
   1. External Systems: Test integration points with external services like Redis for caching.
   2. API Integration: Validate API interactions with other components or third-party services.

# Challenges faced :
Deploying and testing a Java web application using Docker containers on AWS EC2 can present several challenges. Here are some common challenges I faced during this process:
1. Infrastructure Configuration: Setting up and configuring the AWS infrastructure (e.g., VPC, subnet, security groups) using Terraform may require understanding AWS networking concepts and best practices.
2. Environment Setup: Ensuring consistent and reliable environment setup across development, testing, and production environments, especially with Docker and Docker Compose configurations.
3. Dependency Management: Managing dependencies for the Java application (e.g., Maven dependencies) and ensuring compatibility with specified Java and Docker versions.
4. Integration Issues: Ensuring smooth integration between different components (e.g., Java application, MySQL database, Redis cache) within Docker containers and across AWS services.

# Conclusion :
In conclusion, deploying a Java web application using Docker containers on AWS EC2 involves integrating various technologies and navigating through several challenges. By leveraging Terraform for infrastructure provisioning, Docker for containerized deployments, and AWS services for scalability and reliability, we've established a robust environment capable of hosting and managing our application effectively.

Throughout this documentation, we've explored:

- Technologies Used: Highlighting the key technologies such as Java, Docker, MySQL, Tomcat, Redis, and AWS services like EC2 and VPC.

- Project Directory Structure: Detailing how the project is organized, including configurations for Docker, Terraform, and Java application files.

- Deployment Process: Step-by-step instructions on using Terraform to provision AWS infrastructure, deploy Docker containers, and configure the application environment.

- Testing and Validation: Strategies for testing the deployed application, including functional, performance, security, and compatibility testing using various tools.

- Challenges Faced: Identifying common challenges in infrastructure setup, environment configuration, integration, security, and scalability, and providing insights into overcoming these obstacles.

Moving forward, continuous monitoring, optimization, and iterative improvements will be essential to maintain application performance and reliability. By implementing best practices in deployment automation, security, and scalability, we ensure that our Java web application on AWS EC2 remains efficient and resilient in meeting business requirements.

This documentation serves as a comprehensive guide, empowering stakeholders and team members with the knowledge to manage, enhance, and scale the deployed application effectively. It underscores the importance of robust deployment strategies and proactive management in achieving long-term success in cloud-based application hosting.





