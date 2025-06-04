terraform {
  backend "s3" {}
}

variable vpc_id {
  type = string
}

variable interface_endpoints {
  type = list(string)
}

variable gateway_endpoints {
  type = list(string)
}

variable cidr_block {
  type = string
}

variable subnet_ids {
  type = list(string)
}


# ==================================================================================

resource "aws_security_group" "secgrp" {
    name        = "vpce-secgrp"
    description = "Allow all in and out from/to cidr block"
    vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
    security_group_id = aws_security_group.secgrp.id
    ip_protocol       = "tcp"
    cidr_ipv4         = var.cidr_block
    from_port         = 443
    to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
    security_group_id = aws_security_group.secgrp.id
    ip_protocol       = "tcp"
    cidr_ipv4         = var.cidr_block
    from_port         = 443
    to_port           = 443
}

resource "aws_vpc_endpoint" "vpce-i" {
  count               = length(var.interface_endpoints)
  vpc_id              = var.vpc_id
  service_name        = var.interface_endpoints[count.index]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  
  security_group_ids = [
    aws_security_group.secgrp.id
  ]
}

resource "aws_vpc_endpoint" "vpce-g" {
  count               = length(var.gateway_endpoints)
  vpc_id              = var.vpc_id
  service_name        = var.gateway_endpoints[count.index]
  vpc_endpoint_type   = "Gateway"
}

# ==================================================================================

output vpce_i_arns {
  value = aws_vpc_endpoint.vpce-i[*].arn
}

output vpce_i_ids {
  value = aws_vpc_endpoint.vpce-i[*].id
}

output vpce_g_arns {
  value = aws_vpc_endpoint.vpce-g[*].arn
}

output vpce_g_ids {
  value = aws_vpc_endpoint.vpce-g[*].id
}
