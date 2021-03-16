variable "name" {
  default = "aurora-serverless"
}
variable "db_name" {
  default = "aurora_db"
}
variable "db_username" {
  default = "admin"
}
variable "db_password" {
}
variable "apply_immediately" {
  default = false
}
variable "backup_retention_period" {
  default = 30
}
variable "preferred_backup_window" {
  default = "01:00-05:00"
}
variable "min_capacity" {
  default = 2
}
variable "max_capacity" {
  default 4
}
variable "auto_pause" {
  default = false
}
variable "seconds_until_auto_pause" {
  default = 300
}
variable "deletion_protection" {
  default = true
}


resource "aws_rds_cluster_parameter_group" "parameter-group" {
  name = "${var.name}-parameter-group"
  family = "aurora5.6"
  description = "RDS cluster parameter group"
}

resource "aws_rds_cluster" "rds_aurora" {
  depends_on = ["aws_rds_cluster_parameter_group.parameter-group"]
  engine_mode = "serverless"
  skip_final_snapshot = false
  cluster_identifier = "${var.name}-cluster"
  database_name = var.db_name
  master_username = var.db_username
  master_password = var.db_username
  final_snapshot_identifier = "${var.name}-final-snapshot"
  db_cluster_parameter_group_name = "${var.name}-parameter-group"
  apply_immediately = "${var.apply_immediately}"
  snapshot_identifier = "snapshot-${var.name}"
  deletion_protection = "${var.deletion_protection}"
  backup_retention_period = "${var.backup_retention_period}"
  preferred_backup_window = "${var.preferred_backup_window}"

  scaling_configuration {
    min_capacity = "${var.min_capacity}"
    max_capacity = "${var.max_capacity}"
    seconds_until_auto_pause = "${var.seconds_until_auto_pause}"
    auto_pause = "${var.auto_pause}"
  }
}


output "aurora_endpoint" {
  value = "${aws_rds_cluster.rds_aurora.endpoint}"
}
output "aurora_cluster_id" {
  value = "${aws_rds_cluster.rds_aurora.id}"
}

/**
  Usage
  1. update the path
  2. changes variables, listed above
  3. make sure to configure the ENVIRONMENT variable TF_VAR_DB_PASSWORD so you don't commit the password to git
module "aurora-serverless" {
  source = "../path/to/module/aurora-serverless"
  name = "demo"
  auto_pause = true // this will go to sleep once its idle good for testing purposes in production will want to set this false
}
*/