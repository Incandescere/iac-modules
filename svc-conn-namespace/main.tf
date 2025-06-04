terraform {
  backend "s3" {}
}

variable name {
  type = string
}

# ==================================================================================

resource "aws_service_discovery_http_namespace" "svc-disc-namespace" {
  name = "svc-conn-${var.name}"
}
# ==================================================================================

output arn {
  value = aws_service_discovery_http_namespace.svc-disc-namespace.arn
}

output id {
  value = aws_service_discovery_http_namespace.svc-disc-namespace.id
}
