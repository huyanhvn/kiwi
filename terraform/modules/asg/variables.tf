variable "subnets" { type = "list" }
variable "vpc_id" {}
variable "tags" { 
  type = "map"
  default = {}
}
variable "aws_region" {}
variable "ssh_key_name" {}
variable "ssh_ingress" {}
variable "s3_bucket" {}
variable "lb_sg_id" {}
variable "target_group_arns" { type = "list" }

