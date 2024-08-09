# AWS ECR Integration with Jenkins and ECS Cluster and Service Setup

This guide provides a step-by-step process for integrating AWS ECR with Jenkins, followed by the setup of an ECS cluster and service for deploying the `vprofile` application.

## Part 1: AWS ECR Integration with Jenkins

### Step 1: Log in to Jenkins Instance and Update/Install AWS CLI

1. **SSH into Jenkins Instance:**
   ```bash
   ssh ubuntu@<your_jenkins_instance_ip>
   ```

2. **Update the System and Install AWS CLI:**
   ```bash
   sudo apt-get update
   sudo apt-get install awscli -y
   ```

### Step 2: Install Docker on Jenkins Instance

1. **Install Docker:**
   ```bash
   sudo apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release

   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io -y
   ```

2. **Add Jenkins User to Docker Group:**
   ```bash
   sudo usermod -aG docker jenkins
   ```

3. **Verify Jenkins User Membership:**
   ```bash
   id jenkins
   ```

4. **Reboot the Instance to Apply Changes:**
   ```bash
   sudo reboot
   ```

### Step 3: AWS Setup

1. **Create IAM User with Required Permissions:**
   - Navigate to AWS Management Console -> IAM -> Users -> Add User.
   - Set **Username** to `jenkins`.
   - Attach the following policies directly:
     - `AmazonEC2ContainerRegistryFullAccess`
     - `AmazonECS_FullAccess`
   - Click on **Create User**.

2. **Create Access Key for the IAM User:**
   - Go to **IAM** -> **Users** -> `jenkins` -> **Security Credentials** -> **Create Access Key**.
   - Select **Command Line Interface (CLI)**.
   - Note the **Access Key ID** and **Secret Access Key**.

3. **Create ECR Repository:**
   - Navigate to AWS Management Console -> ECR -> Repositories -> Create repository.
   - Set **Repository name** to `vprofileappimg`.
   - Click **Create repository**.

### Step 4: Jenkins Setup

1. **Install Jenkins Plugins:**
   - Go to **Manage Jenkins** -> **Manage Plugins** -> **Available**.
   - Search and install the following plugins:
     - `Amazon ECR`
     - `Docker Pipeline`
     - `AWS SDK for Credentials`
     - `CloudBees Docker Build and Publish`

2. **Add AWS Credentials in Jenkins:**
   - Go to **Manage Jenkins** -> **Manage Credentials** -> **(Jenkins) -> Global credentials (unrestricted)** -> **Add Credentials**.
   - Select **AWS Credentials**.
   - Set the **ID** and **Description** to `awscreds`.
   - Enter the **Access Key ID** and **Secret Access Key** obtained earlier.

## Part 2: ECS Cluster and Service Setup

### 1. Create ECS Cluster

- **Cluster Name:** `vprofile`
- **Subnets:** Select all available subnets in the region.
- **Monitoring:** Enable Container Insights.
- **Tags:** Add relevant tags for easy identification and resource management.

### 2. Create Task Definition

- **Task Definition Name:** `vprofileapptask`
- **Launch Type:** AWS Fargate
- **Operating System:** Linux
- **Architecture:** x86_64
- **CPU and Memory:** 1 vCPU, 2GB Memory
- **Container Configuration:**
  - **Container Name:** `vproapp`
  - **Image URI:** Enter the ECR URI for your application image.
  - **Container Port:** 8080
- **Tags:** Add relevant tags for easy identification.

### 3. ECS Roles

- **Attach IAM Policies:**
  - Search and attach the `CloudWatchLogsFullAccess` policy.
  - Click "Add Permission" to save changes.

### 4. Create Service

- **Launch Type:** Fargate
- **Service Type:** Service
- **Task Definition Family:** Select `vprofileapptask` and its latest revision.
- **Service Name:** `vprofileappsvc`
- **Desired Task Count:** 1
- **Deployment Failure Detection:** Enable for better monitoring.
- **Security Group:**
  - **Name:** `vprofileappecselb-sg`
  - **Inbound Rules:**
    - Allow HTTP (Port 80) from anywhere.
    - Allow custom TCP (Port 8080) from anywhere.
- **Load Balancer:**
  - **Type:** Application Load Balancer
  - **Name:** `vprofileappelbecs`
  - **Listener Ports:** 80 (HTTP)
  - **Target Group:**
    - **Name:** `vproecstg`
    - **Health Check Path:** `/login`
  - **Mapping:** Map container port `8080` to load balancer port `80`.

