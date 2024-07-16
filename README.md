# Scalable Web Application Infrastructure on AWS

# Introduction :

This project aims to set up a scalable, highly available web application infrastructure on AWS using Terraform. The infrastructure is designed to automatically scale based on demand, ensuring reliability and performance. The setup includes containers for MySQL, Tomcat, and Redis, with instances always pulling the latest application version from GitHub.. By following this guide, you will learn how to:

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
   5. Allow HTTP (port 80) from anywhere
   6. Allow all outbound traffic.
- Launch Configuration: Defines the configuration template used by Auto Scaling to launch EC2 instances, specifying instance type, AMI, key pair, security groups, and initialization script.
- Auto Scaling Group: Manages a group of EC2 instances that automatically scales based on policies, ensuring availability and managing instance lifecycle (creation, termination).Implement auto-scaling policies to handle increased load by terminating old instances and creating new ones with the latest changes from the Git repository.
- Application Load Balancer (ALB) : Routes incoming HTTP/HTTPS traffic to multiple EC2 instances across multiple Availability Zones, enhancing fault tolerance and load distribution.
- ALB Target Group: Specifies a group of instances (targets) registered with the ALB, enabling the ALB to route traffic to these instances based on configured criteria.
- ALB Listeners: Configures the ports and protocols (HTTP/HTTPS) for the ALB to listen for incoming traffic and forward it to the associated target group.
- CloudWatch Alarms: Monitors metrics (e.g., CPU utilization) of EC2 instances and triggers actions (e.g., scaling policies) based on predefined thresholds.
- Auto Scaling Policies: Defines scaling policies (scaling out and scaling in) that dictate how the Auto Scaling group adjusts the number of instances based on monitored metrics.
- Data Source (AWS Instances) : Retrieves information about instances within the Auto Scaling group, enabling referencing of these instances in other configurations or scripts.


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
- Purpose: This block is used to output the public IP addresses of the instances that are part of the Auto Scaling Group. This can be useful for verification, logging, or other post-deployment activities.
- Components:
1. output "instance_public_ips":
Defines the name of the output variable, which in this case is instance_public_ips.
2. value: Specifies the value that should be output. Here, it is set to data.aws_instances.example_instances.public_ips, which refers to the public IP addresses of the instances fetched using the aws_instances data source.
3. description: Provides a human-readable description of what this output represents. It helps to understand the purpose of the output when reviewing the Terraform configuration or the output in the terminal.

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

# How it Works with Auto Scaling
- First Instance Creation:
When the Auto Scaling Group creates the first instance, the init-script.sh runs, installing Docker, Git, and Docker Compose. It clones the repository and pulls the latest changes at that time. The instance then builds and starts the Docker containers based on the pulled code.

- Subsequent Instance Creations:
For any new instances created by the Auto Scaling Group (for example, in response to increased load), the same init-script.sh runs. The script clones the repository and pulls the latest changes from the Git repository, ensuring that the instance has the most up-to-date version of the code, including any changes and commits made after the first instance was created.
# Ensuring Consistency Across Instances
- By using this script, you ensure that:
The first instance gets the version of the code that exists in the Git repository at the time of its creation.
Any subsequent instances will always pull the latest changes from the Git repository, reflecting any new commits and updates.
All instances created by the Auto Scaling Group will have the same environment setup and run the latest version of your application.
This approach ensures that your application remains consistent and up-to-date across all instances managed by the Auto Scaling Group.
  
# Verification :
- After completion, verify the infrastructure on your cloud provider's console or through command-line tools to ensure resources are provisioned correctly.
  
By following these steps, Terraform automates the process of infrastructure deployment, ensuring consistency and reliability across environments. Always review the execution plan (terraform plan) before applying changes (terraform apply) to prevent unintended modifications to your infrastructure.

# Access and Testing :

- Verification: Access the deployed application via the EC2 instance’s public IP address.
- Ensure the application (Login.war) is accessible at http://<public_ip>:8080/.
- Test functionality and verify database operations against MySQL (jdbc:mysql://<public_ip>:3306/loginapp).
- Access the application through a load balancer DNS.
( Automatically apply changes from the GitHub repository whenever they are committed.)


# Testing :
# Integration Testing
- Infrastructure Validation:
1. Objective: Ensure all AWS resources defined in Terraform are created and configured correctly.
2. Procedure:
     1. Deploy the infrastructure using terraform apply.
     2. Verify the creation of VPC, subnets, Internet Gateway, route tables, security groups, and Auto Scaling configurations in the AWS Management Console.
     3. Confirm that the Application Load Balancer (ALB) and its listeners are set up correctly.
- Application Deployment:
1. Objective: Ensure Docker containers for MySQL, Tomcat, and Redis are deployed and running.
2. Procedure:
      1. Deploy the application using Docker containers on the EC2 instances launched by the Auto Scaling Group.
      2. Access the ALB DNS endpoint and verify that the application is accessible and functioning as expected.
- Load Testing
- Auto Scaling Validation:
1. Objective: Validate that the Auto Scaling Group scales instances based on load.
2. Procedure:
       1. Simulate increased load on the application by generating traffic using tools like Apache JMeter or AWS Load Testing services.
       2. Monitor CloudWatch metrics for CPU utilization and ALB response times.
       3. Verify that the Auto Scaling Group launches new instances and terminates old instances as needed to maintain performance.
- Continuous Integration (CI) Testing
- Git Integration:
1. Objective: Ensure that changes committed to the Git repository are automatically reflected in new instances.
2. Procedure:
       1. Make changes to the application code and configuration.
       2. Commit and push changes to the Git repository.
       3. Monitor instance creation and verify that new instances launched by the Auto Scaling Group pull the latest changes from the Git repository during initialization.
   
# Challenges faced :
- Infrastructure Setup
1. AWS Resource Limits:
     1. Challenge: Initially faced limits on AWS resources such as VPCs, subnets, and security groups.
     2. Resolution: Adjusted Terraform configurations to optimize resource allocation and utilized AWS service quotas management.
- Docker Containerization
2. Container Networking:
     1. Challenge: Ensuring proper networking setup between MySQL, Tomcat, and Redis containers.
     2. Resolution: Implemented Docker Compose for container orchestration and configured custom networks to facilitate communication.
- Auto Scaling and Load Balancing
3. Auto Scaling Policies:
     1. Challenge: Fine-tuning Auto Scaling policies to effectively respond to varying traffic loads.
     2. Resolution: Implemented CloudWatch alarms and adjusted scaling policies based on performance metrics to optimize instance scaling.
- Git Integration
4. Git Repository Synchronization:
     1. Challenge: Ensuring new instances pull the latest application code from the Git repository.
     2. Resolution: Developed a custom initialization script in the launch configuration to automate Git repository synchronization during instance startup.
        
# Conclusion :

In conclusion, the implementation of this scalable and highly available web application infrastructure on AWS using Terraform has demonstrated several key achievements and insights:

1. Scalability and Elasticity: By leveraging AWS Auto Scaling and Application Load Balancer, the infrastructure dynamically adjusts to varying traffic loads, ensuring optimal performance and resource utilization.

2. High Availability: The setup of multiple Availability Zones for subnets, coupled with automated failover mechanisms, enhances application availability and resilience against infrastructure failures.

3. Infrastructure as Code (IaC): Adopting Terraform for provisioning and managing infrastructure has streamlined deployment processes and enabled consistent, repeatable deployments across development, staging, and production environments.

4. Containerized Deployment: Utilizing Docker containers for MySQL, Tomcat, and Redis has facilitated easier application deployment and management, enhancing flexibility and scalability.

5. Continuous Integration/Continuous Deployment (CI/CD): Integrating Git repository synchronization with instance initialization ensures that new instances always deploy the latest application version, promoting rapid iteration and deployment cycles.

6. Security and Compliance: Implementing secure access controls through AWS Security Groups and maintaining compliance with best practices for cloud infrastructure security has ensured a robust and protected environment.

7. Documentation and Knowledge Sharing: Documenting infrastructure configurations, deployment procedures, and challenges faced has fostered knowledge sharing among team members and facilitated ongoing maintenance and support.

Moving forward, continuous monitoring and periodic review of infrastructure performance metrics will be essential to optimize resource usage and maintain high availability. This project serves as a foundation for future enhancements and scalability, aligning with industry best practices in cloud architecture and DevOps methodologies.





