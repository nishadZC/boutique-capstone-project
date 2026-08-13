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
boutique-capstone-project/
├── .github/
│   └── workflows/
├── gitops/
│   ├── k8s/
│   ├── argo-cd.yml
│   ├── kustomization.yml
│   ├── namespace.yml
│   └── secrets.yml
└── projects/
    ├── boutique-microservices/
    ├── Infrastructure/
    ├── Issues.md
    └── README.md
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

## Simulating Traffic and Monitoring

If you are using the `simulate-traffic.sh` script to test metrics in Grafana, ensure you point the URL to the API Gateway to properly trigger API metrics:

```bash
# Example URL in simulate-traffic.sh
URL="http://<your-ingress-url>/api/products"
```
If you send traffic to the root (`/`), it will hit the React frontend and not register on the backend API Grafana dashboards.

**Grafana Dashboard Enhancements**
The provided Grafana dashboard (`gitops/base/k8s/grafana-dashboard.yml`) includes panels to track the total requests to the gateway.
To track request breakdowns by microservice, PromQL queries like these are included:
- `sum by (route) (http_requests_total{service_name="gateway"})` (Breakdown of all API routes)
- `sum(http_requests_total{service_name="gateway", route=~"^/api/auth.*"})` (Auth requests only)
