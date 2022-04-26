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