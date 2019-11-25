variable "aws_region" {}
variable "vpc_id" {}
variable "tags" { 
  type = "map"
  default = {}
}
variable "lb_ingress" {}
variable "subnets" { type = "list" }
variable "s3_bucket" {}