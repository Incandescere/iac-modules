terraform {
  backend "s3" {}
}

variable url {
  type = string
}

variable audiences {
  type = list(string)
}

# ==================================================================================

resource "aws_iam_openid_connect_provider" "oidc_idp" {
  url            = "https://${var.url}"
  client_id_list = var.audiences
}

# ==================================================================================

output arn {
  value = aws_iam_openid_connect_provider.oidc_idp.arn
}