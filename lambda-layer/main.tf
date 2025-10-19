terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable bucket_name {
  type = string
}

variable zipfile_path {
  type = string
}

variable compatible_runtimes {
  type = list(string)
  default = ["python3.12"] 
}

variable compatible_architectures {
  type = list(string)
  default = ["x86_64"]
}

# ==================================================================================

resource "aws_lambda_layer_version" "layer" {
  s3_bucket = var.bucket_name
  s3_key = var.zipfile_path
  layer_name = "lambda-layer-${var.project_name}-${var.name}"
  compatible_runtimes = var.compatible_runtimes
  compatible_architectures = var.compatible_architectures
}

# ==================================================================================

output arn {
  value = aws_lambda_layer_version.layer.arn
}

output id {
  value = aws_lambda_layer_version.layer.id
}

output layer_arn {
  value = aws_lambda_layer_version.layer.layer_arn
}
