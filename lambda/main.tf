terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable proj_name {
  type = string
}

variable package_type {
  type = string
  default = "Zip"
}

variable execution_role_arn {
  type = string
}

variable description {
  type = string
}

variable env_vars {
  type = list(map(string))
}

variable filename {
  type = string
}

variable handler {
  type = string
}

variable runtime {
  type = string
  default = "python 3.12"
}

# ==================================================================================

resource "aws_lambda_function" "lambda_zip" {
  count = var.package_type == "Zip"? 1 : 0
  function_name = "lambda-${var.proj_name}-${var.name}"
  package_type = var.package_type
  role = var.execution_role_arn
  description = var.description
  env_vars = var.env_vars
  filename = var.filename
  handler = var.handler
  runtime = var.runtime
}

# ==================================================================================

output zip_arn {
  value = aws_lambda_function.lambda_zip.arn
}

output zip_id {
  value = aws_lambda_function.lambda_zip.id
}
