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

variable "lock_resource_group" {
  type        = bool
  description = "lock the resource group"
  default     = false
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

# database specific variables
variable "db_sku" {
  type        = string
  description = "database SKU size"
  default     = "GP_Standard_D8ds_v4"
}

variable "db_storage_mb" {
  type        = number
  description = "db storage size in MiB"
  default     = 524288 # MebiBytes (512GiB)

  validation {
    condition     = contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408], var.db_storage_mb)
    error_message = "The instance type must be one of [32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408]"
  }
}

variable "postgres_version" {
  type        = string
  description = "postgres version"
  default     = "13"
}
