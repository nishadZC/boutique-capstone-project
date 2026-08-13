module "boutique" {
  source = "../../modules/boutique_cluster"

  region            = var.region
  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  subnets           = var.subnets
  cluster_name      = var.cluster_name
  node_group_name   = var.node_group_name
  instance_types    = var.instance_types
  capacity_type     = var.capacity_type
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
  disk_size         = var.disk_size
  teams_webhook_url = var.teams_webhook_url
}
