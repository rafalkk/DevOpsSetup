## 1. Project Overview

- **Title**: Automated Infrastructure Setup and Deployment
- **Description**: DevOps pipeline follows the GitOps principle. Tailored for my personal projects.
- **Technologies Used**:
  - **Infrastructure as Code**: Terraform
  - **Configuration Management**: Ansible
  - **Scripting**: Python, Bash
  - **Continuous Integration/Continuous Deployment (CI/CD)**: GitHub Actions
  - **Containerization**: Docker, Docker Compose
  - **Cloud Provider**: Oracle Cloud Infrastructure

## 2. Detailed Breakdown

This configuration follows the GitOps principle, storing all infrastructure configurations in text files within a Git repository. Only the Terraform state file is stored on HashiCorp Cloud. The main execution is orchestrated by GitHub Actions, with secrets managed using GitHub Secrets.

**Terraform Initialization and Execution**:
- The GitHub Actions workflow begins by checking out the repository and setting up Terraform.
- Terraform is initialized, and an execution plan is created and applied, provisioning the required Oracle Cloud Infrastructure resources.
- The Terraform configuration includes OCI instance creation and the setup of SSH authorized keys and SSH host certificates.

**Dynamic Ansible Inventory Creation**:
- A Python script generates an inventory file (`inventory.ini`) based on the infrastructure provisioned by Terraform. Inventory file is later used by Ansible.

**Ansible Configuration Management**:
- SSH keys are set up for Ansible, and a `known_hosts` file is created using the public host certificate.
- Two Ansible playbooks are executed:
  - **docker-node-setup.yml**: Configures the nodes to ensure Docker is properly set up and running.
  - **docker-compose-run.yml**: Deploys the application using Docker Compose.

## 3. Documentation

### Secrets Required to Run Configuration (GitHub Actions Secrets)
- **HOST_CA_PRIVATE_KEY**: Private key for issuing host certificates to authenticate hosts to users.
- **HOST_CA_PUBLIC_KEY**: Public key for clients to automatically trust the host based on the certificate's identity.
- **OCI_COMPARTMENT_OCID**: Identifier in Oracle Cloud Infrastructure (OCI) that specifically refers to a compartment within a tenancy.
- **OCI_FINGERPRINT**: Fingerprint of the public key required for authentication in OCI.
- **OCI_PRIVATE_KEY_PATH**: Private key used for authentication in Oracle Cloud Infrastructure (the .pem file is generated from this key).
- **OCI_REGION**: Region information for Oracle Cloud Infrastructure services where the configuration is to be deployed.
- **OCI_SSH_PRIVATE_KEY**: Private SSH key required for accessing instances in Oracle Cloud Infrastructure.
- **OCI_SSH_PUBLIC_KEY**: Public SSH key associated with the private key used for accessing instances in Oracle Cloud Infrastructure.
- **OCI_TENANCY_OCID**: Identifier used in Oracle Cloud Infrastructure (OCI) to uniquely distinguish a tenancy.
- **OCI_USER_OCID**: Identifier in Oracle Cloud Infrastructure (OCI) that specifically refers to a user within a tenancy.
- **TF_API_TOKEN**: API token required for authentication and access to Terraform Cloud services.

### File structure and its purpose

```plaintext
.
├── .github
│   └── workflows
│       └── infra.yaml
├── ansible
│   └── playbooks
│       ├── docker-node-setup.yml
│       └── docker-compose-run.yml
├──docker_services
|   └── docker-compose.yml
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf (optional)
│   └── userdata.sh
└──inventory_create.py
```
#### .github/workflows/
- **infra.yaml**: GitHub Action file that runs all infrastructure automation in sequence, triggered by hand or by updating the main branch.

#### ansible/playbooks/
- **docker-node-setup.yml**: Adds Docker and Podman repository, installs required packages and Python libraries required to run Docker, updates, and runs Docker.
- **docker-compose-run.yml**: Copy `docker_services/docker-compose.yml` file to the node and runs it, removing previous instances.

#### docker_services/
- **docker-compose.yml**: Docker Compose file where all applications are specified, additionally use containrrr/watchtower to ensure all apps are updated.

#### terraform/
- **main.tf**:
  - Provider Configuration: sets up the Oracle Cloud Infrastructure (OCI) provider with necessary credentials and region information.
  - Resource Definitions: specifies OCI resources, such as compute instances, including details like availability domain, compartment ID, instance shape, VNIC details, SSH keys, and user data scripts for initialization.
    - Metadata: SSH keys for conection to instances and cloud-init based script, in this case, used to populate instances with host certificates.
- **Variables.tf**: Contains variables used in the Terraform configuration.
- **Outputs.tf** (optional): Contains outputs of the Terraform configuration, such as resource IDs or connection details, useful for post-deployment operations or monitoring.
- **Userdata.sh**: Used to sign SSH host keys. When clients connect to the server, they can verify the server's identity using the host certificate signed by the Certificate Authority (CA). It is used by Terraform when deploying servers using the cloud-init mechanism. 

#### inventory_create.py
- Python script that, during the GitHub Action workflow, generates an inventory file (`inventory.ini`) for Ansible.
