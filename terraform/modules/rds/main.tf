resource "aws_rds_cluster" "kiwi" {
  cluster_identifier      = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-db"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = var.availability_zones
  database_name           = "kiwi"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  tags                    = var.tags
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
    name          = "${var.tags["Environment"]}_${var.tags["AppName"]}_aurora_db_subnet_group"
    description   = "Allowed subnets for Aurora DB cluster instances"
    subnet_ids    = var.subnets
    tags          = var.tags
}

resource "aws_rds_cluster_instance" "kiwi-1" {
  apply_immediately       = true
  cluster_identifier      = aws_rds_cluster.kiwi.id
  identifier              = "kiwi-1"
  instance_class          = "db.t2.small"
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
}

# Outputs
output "db_endpoint" {
    value = aws_rds_cluster.kiwi.endpoint
}