variable "org_service_url" {
  type = string
}

variable "personal_access_token" {
    type = string
}

terraform {
  required_providers {
    azuredevops = {
        source = "microsoft/azuredevops"
        version = ">=0.1.0"
    }

    azurerm = {
        source = "hashicorp/azurerm"
        version = ">=3.10.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-azdo-infrastructure"
    storage_account_name = "azdoinfrastructure"
    container_name = "tfstate"
  }
}

provider "azuredevops" {
  org_service_url = var.org_service_url
  personal_access_token = var.personal_access_token
}

resource "azuredevops_project" "first_project" {
  name = "First Project"
  description = "Constructed with Terraform"
}