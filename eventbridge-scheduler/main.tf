terraform {
  backend "s3" {}
}

variable project_name {
  type = string
}

variable name {
  type = string
}

variable schedule_expression {
  type = string
}

variable target_arn {
  type = string
}

variable role_arn {
  type = string
}

variable input {
  type = map(string)
  default = {}
}

variable timezone {
  type = string
  default = "Asia/Singapore"
}

# ==================================================================================

resource "aws_scheduler_schedule" "schedule" {
  name = "eb-scheduler-${var.project_name}-${var.name}"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.schedule_expression
  target {
    arn = var.target_arn
    role_arn = var.role_arn
    input = length(var.input) > 0 ? jsonencode(var.input) : null
  }
  schedule_expression_timezone = var.timezone
}

# ==================================================================================

output arn {
  value = aws_scheduler_schedule.schedule.arn
}

output id {
  value = aws_scheduler_schedule.schedule.id
}
