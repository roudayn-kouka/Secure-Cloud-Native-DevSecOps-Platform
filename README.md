
# Secure Cloud-Native DevSecOps Platform

**Designed and maintained by [Roudayna Kouka](https://github.com/roudayn-kouka)**

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonwebservices)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?logo=kubernetes)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)
![Argo CD](https://img.shields.io/badge/Argo_CD-GitOps-EF7B4D?logo=argo)
![Security](https://img.shields.io/badge/DevSecOps-Security-green)
![License](https://img.shields.io/badge/License-Apache_2.0-blue)

## Overview

A **cloud-native, security-focused DevSecOps platform** demonstrating the end-to-end lifecycle of a containerized three-tier application on **Amazon Web Services (AWS)**.

The platform combines a **React-based Tetris game**, a **Node.js/Express leaderboard API**, and an encrypted **Amazon RDS for MySQL** database, orchestrated through **Amazon Elastic Kubernetes Service (EKS)**.

Infrastructure provisioning, application delivery, security validation, and observability are integrated into a unified workflow using **Terraform, Jenkins, SonarQube, Trivy, Helm, Argo CD, Prometheus, and Grafana**.

The architecture emphasizes **Infrastructure as Code (IaC), shift-left security, GitOps automation, least-privilege access, scalability, and operational visibility**.

### Key Capabilities

- **Infrastructure Automation:** Reproducible AWS infrastructure provisioning using Terraform.
- **Container Orchestration:** Kubernetes workloads deployed on Amazon EKS with Helm.
- **Continuous Integration:** Jenkins pipelines for application builds, testing, security scanning, and image publishing.
- **DevSecOps:** Automated code quality, dependency, container, and infrastructure security checks.
- **GitOps Delivery:** Declarative Kubernetes deployments managed by Argo CD.
- **Secrets Management:** AWS Secrets Manager integration through External Secrets Operator.
- **Observability:** Prometheus metrics, Grafana dashboards, and Alertmanager notifications.
- **Resilience:** Health probes, Horizontal Pod Autoscaling (HPA), and PodDisruptionBudgets (PDB).

---

## Architecture

<p align="center">
  <img
    src="./public/assets/Plateforme DevSecOps Tetris sur Amazon EKS.gif"
    alt="Secure Cloud-Native DevSecOps Platform Architecture"
    width="80%"
  />
</p>

<p align="center">
  <em>End-to-end architecture illustrating AWS infrastructure, CI/CD security gates, GitOps delivery, and observability.</em>
</p>

### Architecture Layers

| Layer | Technologies | Responsibilities |
|---|---|---|
| Frontend | React, Nginx, Docker | Interactive Tetris game and leaderboard interface |
| Backend | Node.js, Express | REST API, score processing, health checks, and metrics |
| Database | Amazon RDS MySQL | Encrypted, managed relational data storage |
| Cloud Infrastructure | AWS VPC, EKS, ECR, RDS, IAM, KMS | Networking, compute, registry, storage, and access control |
| Infrastructure as Code | Terraform | Automated infrastructure provisioning and configuration |
| CI/CD | Jenkins | Build, test, scan, and publish container images |
| Security | SonarQube, OWASP Dependency-Check, Trivy | Code quality, vulnerability analysis, and configuration scanning |
| Kubernetes Delivery | Helm, Argo CD | Declarative deployments and GitOps synchronization |
| Secrets | AWS Secrets Manager, External Secrets Operator | Secure database credential management |
| Monitoring | Prometheus, Grafana, Alertmanager | Metrics collection, visualization, and alerting |

---

## Repository Structure

| Directory / File | Description |
|---|---|
| `frontend/` | React Tetris application with a multi-stage Docker build and unprivileged Nginx runtime |
| `backend/` | Node.js/Express REST API with input validation, parameterized SQL queries, health endpoints, metrics, and unit tests |
| `EKS-TF/` | Terraform infrastructure for Amazon EKS, ECR, encrypted RDS MySQL, VPC networking, KMS, and IAM |
| `Jenkins-Server-TF/` | Terraform provisioning for the Jenkins/SonarQube EC2 environment |
| `charts/tetris/` | Helm chart defining application workloads, networking, autoscaling, secrets, and monitoring resources |
| `argocd/` | Argo CD Application manifests for the platform, External Secrets Operator, and monitoring stack |
| `Jenkins-Pipeline-Code/` | Jenkins pipelines for infrastructure lifecycle management and application CI |
| `docker-compose.yml` | Local development environment |
| `LICENSE` | Project license |
| `NOTICE` | Attribution and third-party notices |

---

## CI/CD and GitOps Workflow

The platform separates **Continuous Integration (CI)** from **Continuous Deployment (CD)** to maintain a controlled, auditable delivery process.

### 1. Continuous Integration — Jenkins

Application changes trigger a Jenkins pipeline that performs automated validation before publishing container images.

**Pipeline stages:**

1. **Source Checkout** — Retrieve application code from GitHub.
2. **Build & Unit Tests** — Install dependencies, build the application, and execute tests.
3. **Static Code Analysis** — Run SonarQube analysis and enforce the quality gate.
4. **Dependency Analysis** — Identify vulnerable dependencies using OWASP Dependency-Check.
5. **Security Scanning** — Run Trivy checks for secrets, dependencies, and Terraform/Helm misconfigurations.
6. **Container Build** — Build optimized Docker images.
7. **Image Vulnerability Scanning** — Block images containing fixable CRITICAL vulnerabilities.
8. **Artifact Publishing** — Push validated images to Amazon ECR.
9. **GitOps Update** — Commit updated container image tags to the Git repository.

### 2. Continuous Deployment — Argo CD

Argo CD continuously reconciles the Kubernetes cluster with the desired state defined in Git.

**Deployment flow:**

`GitHub → Jenkins → Security Gates → Amazon ECR → GitOps Commit → Argo CD → Amazon EKS`

Helm manages the Kubernetes manifests, while Argo CD handles synchronization and drift reconciliation.

This approach separates **image production** from **cluster deployment**, reducing the need for direct Kubernetes deployment access from Jenkins.

---

## Security Architecture

Security controls are incorporated across the infrastructure, application, container, and delivery layers.

### Network Security

- EKS worker nodes and Amazon RDS deployed in private subnets.
- NAT Gateway for outbound connectivity from private workloads.
- Database access restricted to the EKS node security group.
- Kubernetes NetworkPolicies for pod-level traffic control.
- IAM-based access management for AWS resources.

### Data Protection and Secrets Management

- Amazon RDS storage encryption using AWS KMS.
- Encryption of Kubernetes Secrets and ECR repositories.
- Customer-managed KMS key with automatic rotation enabled.
- TLS-enforced MySQL connections.
- Database credentials generated and managed by Amazon RDS.
- AWS Secrets Manager integration with External Secrets Operator.
- No database passwords committed to Git or hardcoded in Terraform configuration.

### Container Hardening

- Multi-stage Docker builds to minimize runtime image size.
- Non-root container execution.
- Read-only root filesystem.
- Dropped Linux capabilities.
- RuntimeDefault seccomp profile.
- Reduced runtime dependencies and attack surface.

### DevSecOps Security Gates

| Tool | Security Control |
|---|---|
| SonarQube | Static analysis and blocking quality gates |
| OWASP Dependency-Check | Third-party dependency vulnerability detection |
| Trivy | Dependency and secret scanning |
| Trivy IaC | Terraform and Helm configuration scanning |
| Trivy Image | Container image vulnerability scanning |
| Amazon ECR | Immutable image tags and scan-on-push |
| AWS KMS | Encryption key management |
| AWS IAM | Access control and least-privilege policies |

**Security policy:** Container images containing fixable CRITICAL vulnerabilities are blocked before publication.

---

## Deployment Guide

### Prerequisites

Before deploying the platform, ensure the following are available:

- An AWS account with the required permissions.
- AWS CLI configured with valid credentials.
- Terraform installed.
- Docker and Docker Compose.
- `kubectl` and Helm.
- An S3 bucket for Terraform remote state.
- An EC2 key pair for the Jenkins server.
- A GitHub repository containing the platform configuration.

### Step 1 — Configure Terraform State

Update the S3 backend configuration in both:

```text
Jenkins-Server-TF/backend.tf
EKS-TF/backend.tf
```

Replace the bucket configuration with your own Terraform state bucket.

### Step 2 — Provision the Jenkins Environment

```bash
cd Jenkins-Server-TF

terraform init

terraform plan -var-file=variables.tfvars

terraform apply -var-file=variables.tfvars
```

Configure Jenkins with the required plugins:

- SonarQube Scanner
- OWASP Dependency-Check
- NodeJS
- Pipeline: AWS Steps

Configure Jenkins credentials:

```text
github
aws-key
```

### Step 3 — Provision AWS Infrastructure

Use the infrastructure Jenkins pipeline:

```text
Jenkins-Pipeline-Code/Jenkinsfile-EKS-Terraform
```

Alternatively, provision manually:

```bash
cd EKS-TF

terraform init

terraform plan -var-file=variables.tfvars

terraform apply -var-file=variables.tfvars
```

Record the following Terraform outputs:

```text
ecr_repository_urls
rds_endpoint
rds_secret_arn
```

### Step 4 — Configure Kubernetes Add-ons

Install and configure:

- Argo CD
- AWS Load Balancer Controller
- External Secrets Operator
- kube-prometheus-stack

Create the Grafana administrator secret using the instructions in:

```text
argocd/app-monitoring.yaml
```

### Step 5 — Configure Helm Values

Update:

```text
charts/tetris/values.yaml
```

Set the appropriate values for:

```yaml
database:
  host: "<RDS_ENDPOINT>"
  externalSecret:
    awsSecretArn: "<RDS_SECRET_ARN>"
```

Also configure the Amazon ECR image repositories and required application settings.

Replace `YOUR-GITHUB-USER` in the Argo CD manifests and Jenkins pipeline configuration.

### Step 6 — Enable GitOps Deployment

After installing Argo CD and configuring the required dependencies:

```bash
kubectl apply -f argocd/
```

Argo CD manages the desired state of:

- Tetris frontend and backend
- External Secrets Operator
- Prometheus monitoring stack
- Grafana dashboards and alerting resources

### Step 7 — Execute the Application Pipeline

Create a Jenkins pipeline using:

```text
Jenkins-Pipeline-Code/Jenkinsfile-Platform
```

Each successful pipeline execution:

1. Validates the application.
2. Runs security checks.
3. Builds and publishes images to Amazon ECR.
4. Updates the image tag in Git.
5. Allows Argo CD to synchronize the updated deployment.

---

## Observability and Alerting

The platform integrates **Prometheus, Grafana, and Alertmanager** to provide visibility into application behavior and Kubernetes health.

### Application Metrics

The Node.js backend exposes:

| Endpoint | Purpose |
|---|---|
| `/api/scores` | Leaderboard score API |
| `/healthz` | Application liveness |
| `/readyz` | Application readiness |
| `/metrics` | Prometheus-compatible metrics |

Collected metrics include:

- HTTP request throughput.
- Request latency histograms.
- Submitted scores.
- Node.js runtime metrics.
- Application availability.

### Alerting Rules

| Alert | Trigger |
|---|---|
| BackendUnavailable | Backend service becomes unavailable |
| HighErrorRate | HTTP 5xx error rate exceeds 5% |
| HighLatency | p95 request latency exceeds 1 second |
| PodCrashLooping | Kubernetes pods repeatedly restart |

Alertmanager groups and routes alerts, with critical notifications configured to repeat hourly.

To enable Slack notifications, configure a receiver in `argocd/app-monitoring.yaml`:

```yaml
- name: default
  slack_configs:
    - channel: "#alerts"
      api_url_file: /etc/alertmanager/secrets/alertmanager-slack/url
```

Mount the corresponding Kubernetes Secret through:

```yaml
alertmanager:
  alertmanagerSpec:
    secrets:
      - alertmanager-slack
```

### Grafana Dashboard

The **Tetris Platform** dashboard is automatically provisioned to visualize application performance and operational health.

---

## Local Development

The application can be launched locally without provisioning AWS infrastructure.

### Start the Application

```bash
docker compose up --build
```

### Access Services

| Service | URL |
|---|---|
| Tetris Frontend | http://localhost:8080 |
| Leaderboard API | http://localhost:3000 |
| Health Check | http://localhost:3000/healthz |
| Readiness Check | http://localhost:3000/readyz |
| Prometheus Metrics | http://localhost:3000/metrics |

### Stop the Application

```bash
docker compose down
```

To remove local volumes as well:

```bash
docker compose down -v
```

**Note:** Removing volumes may permanently delete locally persisted database data.

---

## Cloud Cost Management

**AWS resources used by this project may incur ongoing charges**, including:

- Amazon EKS control plane and worker nodes.
- NAT Gateway.
- Amazon RDS instances and storage.
- EC2 instances hosting Jenkins and SonarQube.
- Amazon ECR storage and associated network traffic.

When the environment is no longer required, use the `destroy` action of:

```text
Jenkinsfile-EKS-Terraform
```

Review the Terraform destruction plan before confirming.

**Important:** Destroying the EKS infrastructure does not necessarily remove the separately provisioned Jenkins environment, S3 state bucket, or other independently managed resources. Review all remaining AWS resources to avoid unexpected charges.

---

## Engineering Focus

This project demonstrates practical experience in:

- **Cloud Engineering:** AWS infrastructure design, networking, managed services, and IAM.
- **DevOps Automation:** Terraform provisioning, Jenkins pipelines, Docker, and Kubernetes.
- **DevSecOps:** Automated security gates, vulnerability management, secrets protection, and container hardening.
- **GitOps:** Declarative deployments, Helm configuration, and Argo CD reconciliation.
- **Site Reliability:** Health checks, autoscaling, monitoring, alerting, and workload resilience.

The platform serves as a hands-on reference for building **secure, automated, observable, and maintainable cloud-native delivery workflows**.

---

## Author

**Roudayna Kouka**  
Software Engineering | Cloud • DevOps • DevSecOps

GitHub: [roudayn-kouka](https://github.com/roudayn-kouka)

---

## License

Licensed under the **Apache License 2.0**.

See [LICENSE](LICENSE) and [NOTICE](NOTICE) for license terms and attribution information.
