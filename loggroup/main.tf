terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

# ==================================================================================

resource "aws_cloudwatch_log_group" "loggrp" {
  name = "cwlg-${var.project_name}-${var.name}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_stream" "logstream" {
  name           = "cwls-${var.project_name}-${var.name}"
  log_group_name = aws_cloudwatch_log_group.loggrp.name
}

# ==================================================================================

output arn {
  value = aws_cloudwatch_log_group.loggrp.arn
}

output id {
  value = aws_cloudwatch_log_group.loggrp.id
}
