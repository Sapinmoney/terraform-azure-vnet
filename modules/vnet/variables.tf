variable "vnet_name" {}
variable "address_space" { default = ["10.0.0.0/16"] }
variable "location" {}
variable "resource_group_name" {}
variable "subnet_prefix" { default = "10.0.1.0/24" }
variable "tags" { type = map(string) }

