variable "location" {
  type    = string
  default = "East US"
  validation {
    condition     = contains(["East US", "West US", "North Europe", "West Europe"], var.location)
    error_message = "The location must be one of: East US, West US, North Europe, West Europe."
  }
}

variable "prefix" {
  type    = string
  default = "boutique-prod"
  validation {
    condition     = length(var.prefix) <= 15
    error_message = "The prefix must be 15 characters or less to prevent resource name length issues."
  }
}

variable "db_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The database password must be at least 8 characters long."
  }
}
