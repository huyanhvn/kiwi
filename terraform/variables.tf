### AWS creds
variable "aws_region" {}

### Common
variable "vpc_id" {}
variable "availability_zones" { type = "list" }
variable "private_subnets" { type = "list" }
variable "public_subnets" { type = "list" }
variable "db_subnets" { type = "list" }
variable "tags" { 
  type = "map" 
  default = {}
}
variable "ssh_key_name" {}
variable "private_ssh_ingress" {}
variable "bastion_ssh_ingress" {}
variable "lb_ingress" {}
variable "s3_bucket" {}

### RDS
variable "db_username" {}
variable "db_password" {}