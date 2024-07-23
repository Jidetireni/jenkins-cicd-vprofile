# jenkins-ci-vprofile

## Continuous Integration for vprofile Web App

This project demonstrates a complete CI/CD pipeline for `vprofile`, a Java web application, using Jenkins. The pipeline integrates the following stages:

1. Fetching the repository from Git.
2. Building the project with Maven.
3. Running unit tests with Maven.
4. Performing code analysis with Checkstyle.
5. Performing static code analysis with SonarQube.
6. Uploading build artifacts to Nexus.
7. Sending notifications to Slack.

The installation script can be used in AWS userdata or run as a script on a local Linux Ubuntu machine.

## Getting Started

### Prerequisites

- Java 11 or later
- Maven 3.6.3 or later
- Jenkins 2.235.1 or later
- Git
- Checkstyle
- SonarQube
- Nexus Repository Manager
- Slack

### Installation

1. **Configure the various servers and run the installation script on each:**

    ```bash
    ./jenkins.sh
    ./nexus.sh
    ./sonar.sh
    ```

2. **Set up Jenkins:**

    - Install Jenkins on your local machine or server.
    - Install the required Jenkins plugins: Git, Maven Integration, Checkstyle, SonarQube Scanner, Nexus Artifact Uploader, and Slack Notification.

3. **Configure Jenkins pipeline:**

    - Create a new Jenkins pipeline project.
    - Copy the contents of the `Jenkinsfile` from this repository into the pipeline script.

## Technologies Used

- **Jenkins:** Automation server for building CI/CD pipelines.
- **Maven:** Build automation tool for managing project dependencies and build lifecycle.
- **Checkstyle:** Static code analysis tool to ensure code style compliance.
- **SonarQube:** Continuous inspection tool for code quality.
- **Nexus:** Repository manager for storing and distributing build artifacts.
- **Slack:** Communication platform for team collaboration and notifications.

## Configuration

### Jenkins Configuration

- Install Jenkins plugins: Git, Maven Integration, Checkstyle, SonarQube Scanner, Nexus Artifact Uploader, Slack Notification.
- Configure SonarQube in Jenkins: Manage Jenkins -> Configure System -> SonarQube Servers.
- Configure Nexus credentials in Jenkins: Manage Jenkins -> Manage Credentials.
- Configure Slack notifications in Jenkins: Manage Jenkins -> Configure System -> Slack.

### Maven Configuration

- Ensure `pom.xml` includes necessary plugins for Checkstyle and SonarQube.

### Checkstyle Configuration

- Include `checkstyle.xml` in the project root directory.

## Contributing

Contributions are welcome! Please fork this repository and submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

