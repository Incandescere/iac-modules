terraform {
  backend "s3" {}
}

variable name {
  type = string
}

# ==================================================================================

resource "aws_s3_bucket" "s3" {
  bucket = var.name
}

# ==================================================================================

output arn {
  value = aws_s3_bucket.s3.arn
}

output id {
  value = aws_s3_bucket.s3.id
}
