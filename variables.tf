# General Variables
variable "location" {
  type        = string
  description = "Azure region/location to deploy to"
  default     = "east us"
}

variable "project" {
  type        = string
  description = "name of project associated with the resource group"
  default     = "myapp"
}

variable "environment" {
  type        = string
  description = "name of environment (dev,qa,uat,prod,etc.)"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "tags to apply to deployed resources"
  default = {
    terraform   = "true",
    project     = "",
    contact     = "",
    environment = "dev"
  }
}

# vnet specific variables
variable "address_space" {
  type        = list(string)
  description = "cidr range used by vnet"
  default     = ["10.0.0.0/16"]
}

variable "subnet_names" {
  type        = list(string)
  description = "list of subnet names to create in vnet"
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "list of subnet cidr ranges to create in vnet"
}
