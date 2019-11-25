provider "aws" {
    region        = var.aws_region
}

module "lb" {
  source          = "./modules/lb"
  tags            = var.tags
  lb_ingress      = var.lb_ingress
  aws_region      = var.aws_region
  subnets         = var.public_subnets
  vpc_id          = var.vpc_id
  s3_bucket       = var.s3_bucket
}

module "rds" {
  source          = "./modules/rds"
  tags            = var.tags
  aws_region      = var.aws_region
  db_username     = var.db_username
  db_password     = var.db_password
  subnets         = var.db_subnets
  availability_zones = var.availability_zones
}

module "asg" {
  source          = "./modules/asg"
  subnets         = var.private_subnets
  tags            = var.tags
  aws_region      = var.aws_region
  ssh_key_name    = var.ssh_key_name
  ssh_ingress     = var.private_ssh_ingress
  s3_bucket       = var.s3_bucket
  lb_sg_id        = module.lb.lb_sg_id
  vpc_id          = var.vpc_id
  target_group_arns = [
    module.lb.http_target_group_arn,
    module.lb.https_target_group_arn
  ]
}

module "bastion" {
  source          = "./modules/bastion"
  vpc_id          = var.vpc_id
  aws_region      = var.aws_region
  subnet_id       = element(var.public_subnets, 0)
  tags            = var.tags
  ssh_key_name    = var.ssh_key_name
  ssh_ingress     = var.bastion_ssh_ingress
}