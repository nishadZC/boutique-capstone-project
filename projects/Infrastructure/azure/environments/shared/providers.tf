terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  cloud {
    organization = "devops-learning-organization"
    workspaces {
      name = "boutique-azure-shared"
    }
  }
}

provider "azurerm" {
  features {}
}
