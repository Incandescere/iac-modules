terraform {
  backend "s3" {}
}

variable cluster_name {
    type = string
}

variable project_name {
    type = string
}

# ==================================================================================
resource "aws_kms_key" "kms-key" {
  description = "Key for ecs-cluster-${var.project_name}-${var.cluster_name}"
}

resource "aws_kms_alias" "kms-alias" {
  name          = "alias/kms-key-${var.project_name}-${var.cluster_name}"
  target_key_id = aws_kms_key.kms-key.key_id
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name = "cwloggrp-${var.project_name}-${var.cluster_name}"
  retention_in_days = 90
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster-${var.project_name}-${var.cluster_name}"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms-key.arn
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name = "cwloggrp-${var.project_name}-${var.cluster_name}"
      }
    }
  }
}

# ==================================================================================

output "arn" {
    value = aws_ecs_cluster.ecs-cluster.arn
}

output "id" {
    value = aws_ecs_cluster.ecs-cluster.id
}
