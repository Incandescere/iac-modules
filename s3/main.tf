terraform {
  backend "s3" {}
}

variable account_no {
  type = string
}

variable project_name {
  type = string
}

variable bucket_name {
  type = string
}

# ==================================================================================

resource "aws_s3_bucket" "s3" {
  bucket = "storage-s3-${var.project_name}-${var.bucket_name}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

//hardcoded bucket policy, dont use bucket ACL
resource "aws_s3_bucket_policy" "bucket_owner_full_control" {
  bucket = aws_s3_bucket.s3.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.account_no}:root"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.s3.arn}/*"
      }
    ]
  })
}

# ==================================================================================

output arn {
  value = aws_s3_bucket.s3.arn
}

output id {
  value = aws_s3_bucket.s3.id
}
