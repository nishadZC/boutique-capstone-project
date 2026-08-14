# Infrastructure as Code (IaC) Guide

This directory contains the automated provisioning scripts for the multi-cloud architecture backing the Boutique application.

## Directory Structure

```text
Infrastructure/
├── ansible/
│   └── sonarqube/           # Playbooks for configuring the SonarQube VM
├── aws/
│   ├── environments/        # Environment-specific deployments (dev, prod, shared)
│   └── modules/             # Reusable Terraform modules (EKS, VPC, RDS)
└── azure/
    ├── environments/        # Environment-specific deployments (dev, prod, shared)
    └── modules/             # Reusable Terraform modules (AKS, VNet, Postgres)
```

## Terraform Methodology

This project utilizes a **Modular Terraform Architecture**:
- **Modules:** Abstract away complex configurations (e.g., an AKS cluster with AGIC, or a Postgres Flexible server). They are stateless and environment-agnostic.
- **Environments:** Concrete implementations of modules. We separate environments (`dev`, `prod`) to ensure isolation. The `shared` environment holds global resources like Container Registries and centralized tooling (SonarQube).

### State Management
Terraform state is managed securely using **Terraform Cloud**. Each environment connects to a specific Terraform Cloud Workspace (e.g., `boutique-azure-dev`) to execute runs remotely and protect sensitive state data.

## Configuration Management (Ansible)

While Terraform provisions the raw infrastructure, **Ansible** is used for configuration management on Virtual Machines. 

Currently, Ansible is used to bootstrap the **SonarQube** server:
1. Terraform provisions an Ubuntu VM and outputs the Public IP.
2. The IP is placed in `ansible/sonarqube/inventory.ini`.
3. The Ansible playbook (`playbook.yml`) runs OS-level configurations: installing Java, setting up PostgreSQL locally, installing the SonarQube binaries, and configuring `systemd` services.

Because Ansible interacts at the OS layer, the exact same playbook works regardless of whether the VM is hosted in AWS EC2 or Azure!
