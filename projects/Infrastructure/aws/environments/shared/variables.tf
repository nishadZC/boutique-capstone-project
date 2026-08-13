variable "region" {
  description = "The name of the region"
  type        = string
}

variable "repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
}
