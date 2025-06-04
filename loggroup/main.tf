terraform {
  backend "s3" {}
}

variable name {
  type = string
}

# ==================================================================================

resource "aws_cloudwatch_log_group" "loggrp" {
  name = "cwlogs-${var.name}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_stream" "logstrm" {
  name           = "logstream-${var.name}"
  log_group_name = aws_cloudwatch_log_group.loggrp.name
}

# ==================================================================================

output arn {
  value = aws_cloudwatch_log_group.loggrp.arn
}

output id {
  value = aws_cloudwatch_log_group.loggrp.id
}
