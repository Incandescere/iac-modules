terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable region {
  type = string
}

# ==================================================================================

resource "aws_ecr_repository" "ecr" {
  name = "ecr-${var.project_name}-${var.name}"
}

# ==================================================================================

output arn {
  value = aws_ecr_repository.ecr.arn
}

output id {
  value = aws_ecr_repository.ecr.id
}

output url {
  value = aws_ecr_repository.ecr.repository_url
}
