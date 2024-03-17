Phase 1: Initial Setup and Deployment
Step 1: Launch EC2 (Ubuntu 22.04):

Provision an EC2 instance on AWS with Ubuntu 22.04.
Connect to the instance using SSH.
Step 2: Clone the Code:

Update all the packages and then clone the code.

Clone your application's code repository onto the EC2 instance:

git clone https://github.com/devopsProjects24/microservice_deploy.git
Step 3: Install Docker and Run the App Using a Container:

Set up Docker on the EC2 instance:

sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ubuntu'
newgrp docker
sudo chmod 777 /var/run/docker.sock
Build and run your application using Docker containers:

docker build -t javawebapp .
docker run -d --name javawebapp -p 8080:8080 javawebapp:1.0

Phase 2: Security

Install SonarQube and Trivy:

Install SonarQube and Trivy on the EC2 instance to scan for vulnerabilities.

sonarqube

docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
To access:

publicIP:9000 (by default username & password is admin)

To install Trivy:

sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy        
to scan image using trivy

trivy image <imageid>
Integrate SonarQube and Configure:

Integrate SonarQube with your CI/CD pipeline.
Configure SonarQube to analyze code for quality and security issues.
Phase 3: CI/CD Setup

Install Jenkins for Automation:

Install Jenkins on the EC2 instance to automate deployment: Install Java
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)

#jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
Access Jenkins in a web browser using the public IP of your EC2 instance.

publicIp:8080

Install Necessary Plugins in Jenkins:

Goto Manage Jenkins →Plugins → Available Plugins →

Install below plugins

1 Eclipse Temurin Installer (Install without restart)

2 SonarQube Scanner (Install without restart) 

3 Email Extension Plugin

Configure Java in Global Tool Configuration
Goto Manage Jenkins → Tools → Install JDK(17) → Click on Apply and Save

SonarQube
Create the token

Goto Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text. It should look like this

After adding sonar token

Click on Apply and Save

The Configure System option is used in Jenkins to configure different server

Global Tool Configuration is used to configure different tools that we install using Plugins

We will install a sonar scanner in the tools.

Install Dependency-Check and Docker Tools in Jenkins

Install Dependency-Check Plugin:

Go to "Dashboard" in your Jenkins web interface.
Navigate to "Manage Jenkins" → "Manage Plugins."
Click on the "Available" tab and search for "OWASP Dependency-Check."
Check the checkbox for "OWASP Dependency-Check" and click on the "Install without restart" button.
Configure Dependency-Check Tool:

After installing the Dependency-Check plugin, you need to configure the tool.
Go to "Dashboard" → "Manage Jenkins" → "Global Tool Configuration."
Find the section for "OWASP Dependency-Check."
Add the tool's name, e.g., "DP-Check."
Save your settings.
Install Docker Tools and Docker Plugins:

Go to "Dashboard" in your Jenkins web interface.
Navigate to "Manage Jenkins" → "Manage Plugins."
Click on the "Available" tab and search for "Docker."
Check the following Docker-related plugins:
Docker
Docker Commons
Docker Pipeline
Docker API
docker-build-step
Click on the "Install without restart" button to install these plugins.
Add DockerHub Credentials:

To securely handle DockerHub credentials in your Jenkins pipeline, follow these steps:
Go to "Dashboard" → "Manage Jenkins" → "Manage Credentials."
Click on "System" and then "Global credentials (unrestricted)."
Click on "Add Credentials" on the left side.
Choose "Secret text" as the kind of credentials.
Enter your DockerHub credentials (Username and Password) and give the credentials an ID (e.g., "docker").
Click "OK" to save your DockerHub credentials.
Now, you have installed the Dependency-Check plugin, configured the tool, and added Docker-related plugins along with your DockerHub credentials in Jenkins. You can now proceed with configuring your Jenkins pipeline to include these tools and credentials in your CI/CD process.

pipeline {
    agent any
    
    tools {
        jdk 'jdk-17'
        maven 'maven3'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        stage('GIT CHECKOUT') {
            steps {
                git branch: 'main', url: 'https://github.com/rahulprakash05/Devops-CICD.git'
            }
        }
        stage('CODE COMPILE') {
            steps {
                sh "mvn clean compile"
            }
        }
        stage('SONARQUBE ANALYSIS') {
            steps {
                withSonarQubeEnv('sonar-scanner') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Devops-CICD \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Devops-CICD '''
                }
            }
        }
        stage('TRIVY SCAN') {
            steps {
                sh " trivy fs --security-checks vuln,config /var/lib/jenkins/workspace/Devops-CICD "
            }
        }
        stage('CODE BUILD') {
            steps {
                sh "mvn clean install"
            }
        }
        stage('DOCKER BUILD') {
            steps {
                script{
                    withDockerRegistry(credentialsId: '87ac728f-7d54-4d3b-aa17-f79bdbf15d04', toolName: 'docker-latest', url: 'https://index.docker.io/v1/') {
                        sh "docker build -t cicddevops ."
                    }
                }
            }
        }
        stage('DOCKER TAG PUSH') {
            steps {
                script{
                    withDockerRegistry(credentialsId: '87ac728f-7d54-4d3b-aa17-f79bdbf15d04', toolName: 'docker-latest', url: 'https://index.docker.io/v1/') {
                        sh "docker tag cicddevops rahulprakash05/cicddevops:$BUILD_ID"
                        sh "docker push rahulprakash05/cicddevops:$BUILD_ID"
                    }
                }
            }
        }
    }
}



If you get docker login failed errorr

sudo su
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

Deploy Application with ArgoCD
Install ArgoCD:

You can install ArgoCD on your Kubernetes cluster by following the instructions provided in the EKS Workshop documentation.

Set Your GitHub Repository as a Source:

After installing ArgoCD, you need to set up your GitHub repository as a source for your application deployment. This typically involves configuring the connection to your repository and defining the source for your ArgoCD application. The specific steps will depend on your setup and requirements.

Create an ArgoCD Application:

name: Set the name for your application.
destination: Define the destination where your application should be deployed.
project: Specify the project the application belongs to.
source: Set the source of your application, including the GitHub repository URL, revision, and the path to the application within the repository.
syncPolicy: Configure the sync policy, including automatic syncing, pruning, and self-healing.
Access your Application

To Access the app make sure port 30007 is open in your security group and then open a new tab paste your NodeIP:30007, your app should be running.
Phase 7: Cleanup

Cleanup AWS EC2 Instances:
Terminate AWS EC2 instances that are no longer needed.
