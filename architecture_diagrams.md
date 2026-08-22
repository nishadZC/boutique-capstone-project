# Boutique Capstone — Architecture Diagrams

---

## 1. High-Level System Architecture

```mermaid
graph TB
    subgraph USER["👤 End User"]
        Browser["Browser"]
    end

    subgraph LOCAL["🐳 Local (Docker Compose)"]
        FE_L["Frontend\nReact · Port 3000"]
        GW_L["API Gateway\nNode.js · Port 3001"]
        AUTH_L["Auth Service\nPort 3002"]
        PROD_L["Product Service\nPort 3003"]
        ORD_L["Orders Service\nPort 3005"]
        PG_L["PostgreSQL\nPort 5432"]
        PROM_L["Prometheus\nPort 9090"]
        GRAF_L["Grafana\nPort 3007"]
    end

    subgraph AWS["☁️ AWS (Production — EKS)"]
        FE_K["Frontend Pod"]
        GW_K["Gateway Pod"]
        AUTH_K["Auth Pod"]
        PROD_K["Product-Service Pod"]
        ORD_K["Orders Pod"]
        PG_K["PostgreSQL StatefulSet\n(EBS PVC)"]
        PROM_K["Prometheus\n(monitoring ns)"]
        GRAF_K["Grafana\n(monitoring ns)"]
        ARGO["ArgoCD\n(argocd ns)"]
    end

    Browser -->|"HTTP"| FE_L
    FE_L --> GW_L
    GW_L --> AUTH_L & PROD_L & ORD_L
    AUTH_L & PROD_L & ORD_L --> PG_L
    PROM_L --> GW_L & AUTH_L & PROD_L & ORD_L
    GRAF_L --> PROM_L

    Browser -->|"kubectl port-forward"| FE_K
    FE_K --> GW_K
    GW_K --> AUTH_K & PROD_K & ORD_K
    AUTH_K & PROD_K & ORD_K --> PG_K
    PROM_K -->|"ServiceMonitor scrape"| GW_K & AUTH_K & PROD_K & ORD_K
    GRAF_K --> PROM_K
    ARGO -->|"GitOps sync"| FE_K & GW_K & AUTH_K & PROD_K & ORD_K
```

---

## 2. Microservices — Request Flow

```mermaid
sequenceDiagram
    participant Browser
    participant Frontend as Frontend (React)
    participant Gateway as API Gateway :3001
    participant Auth as Auth Service :3002
    participant Products as Product Service :3003
    participant Orders as Orders Service :3005
    participant DB as PostgreSQL

    Browser->>Frontend: Load page
    Frontend->>Gateway: POST /auth/login
    Gateway->>Auth: Proxy → /login
    Auth->>DB: SELECT FROM auth_db.users
    DB-->>Auth: User row
    Auth-->>Gateway: JWT { accessToken, refreshToken }
    Gateway-->>Frontend: 200 OK + tokens

    Browser->>Frontend: View products
    Frontend->>Gateway: GET /products (Bearer token)
    Gateway->>Products: Proxy → /products
    Products->>DB: SELECT FROM products_db
    DB-->>Products: Product rows
    Products-->>Gateway: Product list JSON
    Gateway-->>Frontend: 200 OK + products

    Browser->>Frontend: Place order
    Frontend->>Gateway: POST /orders (Bearer token)
    Gateway->>Orders: Proxy → /orders
    Orders->>Products: GET /products/:id (stock check)
    Orders->>DB: INSERT INTO orders_db
    DB-->>Orders: Order created
    Orders-->>Gateway: Order confirmation
    Gateway-->>Frontend: 201 Created
```

---

## 3. Infrastructure — AWS Architecture

```mermaid
graph TB
    subgraph VPC["VPC  (us-east-1)"]
        subgraph AZ_A["AZ: us-east-1a"]
            SN_A["Public Subnet"]
        end
        subgraph AZ_B["AZ: us-east-1b"]
            SN_B["Public Subnet"]
        end
        subgraph AZ_C["AZ: us-east-1c"]
            SN_C["Public Subnet"]
        end

        subgraph EKS["EKS Cluster: boutique-eks (k8s 1.34)"]
            subgraph NG["Node Group — m7i-flex.large (1–2 nodes)"]
                subgraph NS_BOUTIQUE["Namespace: boutique-dev"]
                    FE_POD["frontend Pod"]
                    GW_POD["gateway Pod"]
                    AUTH_POD["auth Pod"]
                    PROD_POD["product-service Pod"]
                    ORD_POD["orders Pod"]
                    PG_POD["postgres StatefulSet"]
                    PVC["EBS PVC\n(postgres data)"]
                end
                subgraph NS_MON["Namespace: monitoring"]
                    PROM["Prometheus"]
                    GRAF["Grafana"]
                    AM["Alertmanager"]
                end
                subgraph NS_ARGO["Namespace: argocd"]
                    ARGO["ArgoCD Server"]
                end
            end
        end
    end

    subgraph ECR["Amazon ECR"]
        ECR_FE["frontend"]
        ECR_GW["gateway"]
        ECR_AUTH["auth"]
        ECR_PROD["product-service"]
        ECR_ORD["orders"]
        ECR_OSV["order-service"]
        ECR_USR["user-service"]
    end

    PG_POD --- PVC
    ECR_FE -.->|"image pull"| FE_POD
    ECR_GW -.->|"image pull"| GW_POD
    ECR_AUTH -.->|"image pull"| AUTH_POD
    ECR_PROD -.->|"image pull"| PROD_POD
    ECR_ORD -.->|"image pull"| ORD_POD

    AM -->|"Webhook"| TEAMS["MS Teams Channel"]
```

---

## 4. CI/CD Pipeline — GitHub Actions → ECR → ArgoCD

```mermaid
flowchart TD
    DEV["Developer\npushes to main"]

    subgraph GHA["GitHub Actions Pipeline"]
        SONAR["① SonarQube Scan\nCode quality & security analysis"]
        MATRIX["② build-and-push\n7 parallel matrix jobs"]
        TRIVY["③ Trivy Scan\nCRITICAL/HIGH CVE check (OS)"]
        PUSH["④ docker push → ECR\n(tag = git SHA)"]
        PATCH["⑤ update-manifests\nSed image tags in gitops/base/k8s/"]
        COMMIT["⑥ git commit & push\nupdated YAML back to main"]
    end

    subgraph GITOPS["GitOps (ArgoCD)"]
        ARGO_WATCH["ArgoCD watches main branch\ngitops/overlays/dev"]
        ARGO_SYNC["Auto-sync\n(prune + selfHeal)"]
        K8S["EKS Cluster\nboutique-dev namespace"]
    end

    DEV --> SONAR
    SONAR -->|"pass"| MATRIX
    MATRIX --> TRIVY
    TRIVY --> PUSH
    PUSH --> PATCH
    PATCH --> COMMIT
    COMMIT -->|"git push triggers"| ARGO_WATCH
    ARGO_WATCH --> ARGO_SYNC
    ARGO_SYNC --> K8S
```

---

## 5. Observability Stack

```mermaid
graph LR
    subgraph SERVICES["Backend Services (boutique-dev)"]
        GW["/metrics\ngateway"]
        AUTH["/metrics\nauth"]
        PROD["/metrics\nproduct-service"]
        ORD["/metrics\norders"]
    end

    subgraph PROM_STACK["kube-prometheus-stack (monitoring ns)"]
        SM["ServiceMonitor\n(scrape every 15s)"]
        PROM["Prometheus\n:9090"]
        RULES["PrometicRules\nHighTraffic alert\n(>10 req/s for 1m)"]
        AM["Alertmanager"]
    end

    subgraph GRAFANA_STACK["Grafana (monitoring ns)"]
        SIDECAR["Grafana Sidecar\nConfigMap watcher"]
        CM["ConfigMap\ngrafana_dashboard=1"]
        GRAF["Grafana :80\nBoutique Dashboard"]
    end

    subgraph LOGS["Log Forwarding (optional)"]
        FB["Fluent Bit DaemonSet\n(amazon-cloudwatch ns)"]
        CW["CloudWatch\n/eks/boutique/pods"]
    end

    GW & AUTH & PROD & ORD -->|"HTTP scrape"| SM
    SM --> PROM
    PROM --> RULES
    RULES --> AM
    AM -->|"Webhook"| TEAMS["MS Teams"]
    PROM -->|"datasource"| GRAF
    CM -->|"auto-import"| SIDECAR
    SIDECAR --> GRAF
    SERVICES -->|"stdout logs"| FB
    FB --> CW
```

---

## 6. Repository & Directory Structure

```mermaid
graph TD
    ROOT["boutique-capstone-project/"]

    ROOT --> GITHUB[".github/workflows/ci.yaml\nGitHub Actions pipeline"]
    ROOT --> PROJECTS["projects/"]
    ROOT --> GITOPS["gitops/"]
    ROOT --> SIM["simulate-traffic.sh"]

    PROJECTS --> INFRA["Infrastructure/aws/\nTerraform"]
    PROJECTS --> MS["boutique-microservices/"]
    PROJECTS --> README["README.md\n(Deployment Guide)"]

    INFRA --> MOD["modules/\nvpc · eks · ecr · argocd\nboutique_cluster"]
    INFRA --> ENV["environments/shared/\nmain.tf (ECR module)"]

    MS --> FE["frontend/\nReact + TypeScript (Vite)"]
    MS --> BE["backend/services/\nauth · gateway · orders\nproduct-service"]
    MS --> DB["database/init/\nSQL init scripts"]
    MS --> DC["docker-compose.yml"]
    MS --> PROM_CFG["prometheus/ + grafana/\nlocal config"]

    GITOPS --> BASE["base/\nkustomization.yml\nk8s/ manifests (all services)"]
    GITOPS --> OVL["overlays/\ndev + prod patches"]
    GITOPS --> ARGO_APP["argo-cd.yml\nArgoCD Application"]
```

---

## 7. Database Schema Layout

```mermaid
erDiagram
    AUTH_DB {
        string id PK
        string email
        string password_hash
        string first_name
        string last_name
        string phone
        string address
        string refresh_token
        timestamp created_at
    }

    PRODUCTS_DB {
        int id PK
        string name
        text description
        decimal price
        int stock
        string category
        string image_url
        timestamp created_at
    }

    ORDERS_DB {
        int id PK
        string user_id FK
        jsonb items
        decimal total_amount
        string status
        timestamp created_at
    }

    AUTH_DB ||--o{ ORDERS_DB : "user_id"
    PRODUCTS_DB ||--o{ ORDERS_DB : "items[]"
```

---

## 8. Kubernetes Namespace Layout

```mermaid
graph TB
    subgraph CLUSTER["EKS Cluster — boutique-eks"]
        subgraph DEV["boutique-dev namespace"]
            FE_SVC["frontend\nDeployment + Service\n(LoadBalancer / port-forward :3000)"]
            GW_SVC["gateway\nDeployment + ClusterIP :3001"]
            AUTH_SVC["auth\nDeployment + ClusterIP :3002"]
            PROD_SVC["product-service\nDeployment + ClusterIP :3003"]
            ORD_SVC["orders\nDeployment + ClusterIP :3005"]
            PG_SVC["postgres\nStatefulSet + ClusterIP :5432\n+ EBS PVC"]
            SEC["boutique-secrets\n(DB connection strings)"]
        end

        subgraph MON["monitoring namespace"]
            P["Prometheus :9090"]
            G["Grafana :80"]
            A["Alertmanager"]
            SM["ServiceMonitor\n(scrapes boutique-dev)"]
        end

        subgraph ARGO_NS["argocd namespace"]
            AS["ArgoCD Server :443"]
            AR["ArgoCD Repo Server"]
        end
    end

    SEC -.->|"secretKeyRef"| AUTH_SVC & PROD_SVC & ORD_SVC & PG_SVC
    SM -.->|"cross-namespace scrape"| GW_SVC
    AS -->|"apply manifests"| DEV
```
