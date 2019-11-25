variable "aws_region" {}
variable "db_username" {}
variable "db_password" {}
variable "tags" { 
  type = "map"
  default = {}
}
variable "availability_zones" { type = "list" }
variable "subnets" { type = "list" }