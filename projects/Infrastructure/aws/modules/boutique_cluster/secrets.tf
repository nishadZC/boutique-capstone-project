# Create the secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.cluster_name}-db-secret-v3"
  description = "Database password for boutique environment"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    POSTGRES_DB       = "postgres"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = var.db_password
    AUTH_DB_URL       = "postgresql://postgres:${var.db_password}@boutique-postgres:5432/auth_db"
    PRODUCTS_DB_URL   = "postgresql://postgres:${var.db_password}@boutique-postgres:5432/products_db"
    ORDERS_DB_URL     = "postgresql://postgres:${var.db_password}@boutique-postgres:5432/orders_db"
    USERS_DB_URL      = "postgresql://postgres:${var.db_password}@boutique-postgres:5432/users_db"
  })
}

# IAM Role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "${var.cluster_name}-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })
}

# IAM Policy to allow reading the secret
resource "aws_iam_policy" "external_secrets" {
  name_prefix = "ExternalSecretsPolicy-"
  description = "Policy for External Secrets Operator to read from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = [aws_secretsmanager_secret.db_password.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# Install External Secrets Operator via Helm
resource "helm_release" "external_secrets" {
  provider         = helm.eks
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.9.11"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }

  depends_on = [module.eks]
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}
