module "vpc" {
  source = "./modules/vpc"

  vpc_name     = var.vpc_name
  cidr_block   = var.vpc_cidr
  subnet_cidrs = [for s in var.subnets : s.cidr_block]
  availability_zones = [for s in var.subnets : s.availability_zone]
  cluster_name     = var.cluster_name
}


module "eks" {
  source = "./modules/eks"

  cluster_name     = var.cluster_name
  node_group_name  = var.node_group_name

  instance_types = var.instance_types
  min_size       = var.min_size
  desired_size   = var.desired_size
  max_size       = var.max_size

  subnet_ids = module.vpc.subnet_ids
  depends_on = [module.vpc]
}

module "ecr" {
  source = "./modules/ecr"
  repositories = var.repositories
}



module "argocd" {
  source = "./modules/argocd"
  teams_webhook_url = var.teams_webhook_url
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  depends_on = [module.eks, helm_release.aws_load_balancer_controller]
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${module.eks.cluster_name}-aws-load-balancer-controller"

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
            "${replace(module.eks.oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

data "http" "aws_load_balancer_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name_prefix = "AWSLoadBalancerController-"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy      = data.http.aws_load_balancer_controller_iam_policy.response_body
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "helm_release" "aws_load_balancer_controller" {
  provider   = helm.eks
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1"

  create_namespace = false

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "region"
    value = var.region
  }

  depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller, module.eks]
}

resource "helm_release" "ingress_nginx" {
  provider         = helm.eks
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "external"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  depends_on = [module.eks]
}
