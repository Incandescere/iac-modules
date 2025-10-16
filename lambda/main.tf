terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable package_type {
  type = string
  default = "Zip"
}

variable execution_role_arn {
  type = string
}

variable filename {
  type = string
}

variable handler {
  type = string
}

variable runtime {
  type = string
  default = "python3.12"
}

variable env_vars {
  type = map(string)
}

# ==================================================================================

resource "aws_lambda_function" "lambda_zip" {
  count = var.package_type == "Zip"? 1 : 0
  function_name = "lambda-${var.project_name}-${var.name}"
  package_type = var.package_type
  role = var.execution_role_arn
  description = "Lambda function for ${var.project_name}, ${var.name}"
  filename = var.filename
  handler = var.handler
  runtime = var.runtime
  environment {
    variables = var.env_vars
  }
}

# ==================================================================================

output zip_arn {
  value = aws_lambda_function.lambda_zip[*].arn
}

output zip_id {
  value = aws_lambda_function.lambda_zip[*].id
}
