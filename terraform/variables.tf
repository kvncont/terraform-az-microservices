# Azure DevOps
variable "prefix_svc_name" {
  type        = string
  description = "Prefix for service connection name"
  default     = "TF"
}

# Azure 

# Service principal
variable "client_id" {
  type        = string
  description = "Service Principal Client Id"
}

variable "client_secret" {
  type        = string
  description = "Service Principal Client Secret"
}

# Shared variables
variable "suffix_resource_name" {
  type        = string
  description = "Suffix for resource names"
  default     = "kvncontmicroservices"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    "created_by"  = "terraform"
    "environment" = "dev"
  }
}

# VM
variable "vm_admin_passwd" {
  type        = string
  description = "Admin password for vms"
}
