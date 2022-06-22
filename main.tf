variable "TF_VAR_ORG_SERVICE_URL" {
  type = string
}

variable "TF_VAR_PERSONAL_ACCESS_TOKEN" {
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

resource "azuredevops_project" "first_project" {
  name = "First Project"
  description = "Constructed with Terraform"
}

resource "azuredevops_build_definition" "first_build_definition" {
  // azure devops built definition
  name = "First Build Definition"
  project_id = azuredevops_project.first_project.id
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
  }
}