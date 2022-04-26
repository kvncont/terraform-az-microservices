# Shared variables
variable "suffix_resource_name" {
  type        = string
  description = "Suffix for resource names"
  default     = "azdevops-agent-pools"
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
