terraform {
  backend "s3" {}
}

variable vpc_cidr_block {
    type = string
}

variable name {
    type = string
}

variable project_name {
    type = string
}

# ==================================================================================

resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc_cidr_block
    instance_tenancy = "default"

    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "vpc-${var.project_name}-${var.name}"
    }
}

# ==================================================================================

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "default_rtb_id" {
    value = aws_vpc.vpc.default_route_table_id
}