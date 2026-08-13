variable "teams_webhook_url" {
  description = "The MS Teams webhook URL for Alertmanager notifications"
  type        = string
  sensitive   = true
}