variable "solution_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "deployment_location" {
  type = string
  validation {
    condition = contains(["eastus2"], var.deployment_location)
    error_message = "Invalid location. Location must be eastus2"
  }
}

variable "environment" {
  type = string
  validation {
    condition = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Invalid environment. Accepted environment names are dev, stage, or prod"
  }
}

variable "instance_number" {
  type = string
}

variable "tag_creation_date" {
  type = string
}

variable "snet_ip_cidr" {
  type = list(string)
}

variable "tenant_id" {
  type = string
}

variable "vnet_ip_cidr" {
  type = string
}

variable "snet_transit" {
  type = string
}

variable "snet_adb_private" {
  type = string
}

variable "snet_adb_public" {
  type = string
}

variable "snet_k8s" {
  type = string
}


variable "storage_accounts" {
  type = list(object({
    base_name   = string
    containers  = list(string)
  }))
}

variable "azure_personas" {
  type = list(object({
    persona    = string
    members = list(string)
    roles   = list(string)
  }))
}
