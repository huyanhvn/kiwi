# AWS creds
# Assumes being sourced from standard awscli env vars
aws_region = "us-east-1"

# Common
vpc_id = ...
availability_zones = [...]
private_subnets = [ "", "" ]
public_subnets = [ "", "" ]
db_subnets = [ "", "", "" ]
tags = {
  CreatedBy = "huy"
  AppName = "kiwi"
  Environment = "dev"
}
ssh_key_name = "huy-dev"
bastion_ssh_ingress = "0.0.0.0/0"
private_ssh_ingress = "10.192.0.0/16"
lb_ingress = "0.0.0.0/0"
s3_bucket = "huy-dev"

### RDS
db_username = ...
db_password = ...