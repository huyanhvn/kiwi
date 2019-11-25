variable "subnet_id" {}
variable "aws_region" {}
variable "vpc_id" {}
variable "tags" { 
  type = "map"
  default = {}
}
variable "ssh_key_name" {}
variable "ssh_ingress" {}

