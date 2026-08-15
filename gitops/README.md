# GitOps Deployment Strategy

This directory serves as the Single Source of Truth for the state of all Kubernetes clusters in this project. We utilize **ArgoCD** as our GitOps controller and **Kustomize** to manage manifests across multiple environments .

## Directory Layout

```text
gitops/
├── argo-cd-aws-dev.yml      # ArgoCD App definition pointing to aws/overlays/dev
├── argo-cd-azure-dev.yml    # ArgoCD App definition pointing to azure/overlays/dev
├── aws/
│   ├── base/                # Base Kubernetes manifests tailored for AWS (e.g., ALB Ingress)
│   └── overlays/            # Environment patches (dev, prod)
└── azure/
    ├── base/                # Base Kubernetes manifests tailored for Azure (e.g., AGIC Ingress)
    └── overlays/            # Environment patches (dev, prod)
```

## The Kustomize Approach

Instead of managing duplicate YAML files for Dev and Prod, we use Kustomize:

1. **`base/`:** Contains the raw `Deployment`, `Service`, and `Ingress` YAML files. This directory is oblivious to the environment it's running in.
2. **`overlays/<env>/`:** Contains environment-specific configurations. For example, `overlays/prod` might patch the base deployment to increase the `replicas` from 1 to 5, or change resource limits.

## How the Flow Works

1. A developer merges code to `main`.
2. The CI/CD Pipeline (GitHub Actions or Azure DevOps) builds the Docker image and tags it with the commit SHA.
3. The Pipeline runs a script to update the image tag directly in the `gitops/<cloud>/base` files (or via `kustomize edit set image`).
4. The Pipeline commits and pushes this change back to this repository.
5. **ArgoCD** detects the change in this repository.
6. ArgoCD synchronizes the cluster, pulling the new image and applying it safely using rolling updates.
