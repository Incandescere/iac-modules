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

resource "aws_s3_bucket" "s3" {
  bucket = "storage-s3-${var.project_name}-${var.name}"
}

# ==================================================================================

output arn {
  value = aws_s3_bucket.s3.arn
}

output id {
  value = aws_s3_bucket.s3.id
}
