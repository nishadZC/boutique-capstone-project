# DevOps Project

An end-to-end DevOps project that demonstrates how a microservices application can be developed, containerized, deployed to AWS EKS, and managed using CI/CD, GitOps, and monitoring.

## What This Project Covers

* Microservices application development using **React, Node.js, and PostgreSQL**
* Containerization using **Docker and Docker Compose**
* Infrastructure provisioning using **Terraform**
* Kubernetes deployment on **AWS EKS**
* CI/CD automation using **GitHub Actions**
* GitOps-based deployments using **ArgoCD and Kustomize**
* Application monitoring using **Prometheus and Grafana**
* Centralized logging using **AWS Fluent Bit and CloudWatch**
* AWS networking, IAM, ECR, and EKS configuration
* End-to-end deployment and troubleshooting of the application

## Repository Structure

```text
DevOps-Practice-Guide/
├── docs/
│   ├── part1-system-design.md
│   └── part2-workflow.md
│
├── projects/
│   ├── README.md
│   ├── boutique-microservices/
│   └── Infrastructure/
│
├── gitops/
│   ├── argo-cd.yml
│   ├── kustomization.yml
│   └── k8s/
│
└── .github/
    └── workflows/
        └── ci.yml
```

## Tech Stack

| Category           | Technology                 |
| ------------------ | -------------------------- |
| Frontend           | React                      |
| Backend            | Node.js                    |
| Database           | PostgreSQL                 |
| Containers         | Docker, Docker Compose     |
| Orchestration      | Kubernetes, AWS EKS        |
| Infrastructure     | Terraform                  |
| CI/CD              | GitHub Actions             |
| GitOps             | ArgoCD, Kustomize          |
| Monitoring         | Prometheus, Grafana        |
| Logging            | AWS Fluent Bit, CloudWatch |
| Container Registry | Amazon ECR                 |
| Cloud              | AWS                        |
