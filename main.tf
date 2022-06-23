variable "TF_VAR_ORG_SERVICE_URL" {
  type = string
}

variable "TF_VAR_PERSONAL_ACCESS_TOKEN" {
  type = string
}

variable "TF_VAR_GITHUB_PERSONAL_ACCESS_TOKEN" {
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
  org_service_url = var.TF_VAR_ORG_SERVICE_URL
  personal_access_token = var.TF_VAR_PERSONAL_ACCESS_TOKEN
}

resource "azuredevops_project" "express_hello_world_project" {
  name = "Express Hello World"
  description = "Constructed with terraform"
  features = {
    "pipelines" = "enabled"
    "artifacts" = "enabled"
    "boards" = "disabled"
    "repositories" = "disabled"
    "testplans" = "disabled"
  }
}

resource "azuredevops_serviceendpoint_github" "github_service_endpoint" {
  project_id = azuredevops_project.express_hello_world_project.id
  service_endpoint_name = "github"

  auth_personal {
    personal_access_token = var.TF_VAR_GITHUB_PERSONAL_ACCESS_TOKEN
  }

  lifecycle {
    ignore_changes = [
      service_endpoint_name,
      auth_personal
    ]
  }
}

resource "azuredevops_build_definition" "build_code" {
  project_id = azuredevops_project.express_hello_world_project.id
  name = "Build Code"
  agent_pool_name = "Azure Pipelines"

  ci_trigger {
    use_yaml = true
  }

  pull_request_trigger {
    use_yaml = true
    forks {
      enabled = true
      share_secrets = true
    }
  }

  repository {
    repo_type = "GitHub"
    repo_id = "danharrisondev/express-hello-world"
    branch_name = "master"
    yml_path = "deploy/pipelines/azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.github_service_endpoint.id
  }
}
