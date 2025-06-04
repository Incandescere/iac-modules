terraform {
  backend "s3" {}
}

variable name {
    type = string
}

variable vpc_id {
    type = string
}

variable inbound_rules {
    type = list(list(any))
}

variable outbound_rules {
    type = list(list(any))
}

# in/egress rules are of the format
# inegress_rule = [
#     ["protocol", "cidr_1", "from_port", "to_port"], 
#     ["protocol", "cidr_2", "from_port", "to_port"]
# ]

# ==================================================================================
resource "aws_security_group" "secgrp" {
    name        = "${var.name}-secgrp"
    description = "Allow all inbound HTTP traffic and all outbound traffic"
    vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "inbound_rules" {
    count             = length(var.inbound_rules)
    security_group_id = aws_security_group.secgrp.id
    ip_protocol       = var.inbound_rules[count.index][0]
    # ip_protocol       = -1
    cidr_ipv4         = var.inbound_rules[count.index][1]
    from_port         = var.inbound_rules[count.index][2]
    to_port           = var.inbound_rules[count.index][3]
}


resource "aws_vpc_security_group_egress_rule" "outbound_rules" {
    count             = length(var.outbound_rules)
    security_group_id = aws_security_group.secgrp.id
    ip_protocol       = var.outbound_rules[count.index][0]
    # ip_protocol       = -1
    cidr_ipv4         = var.outbound_rules[count.index][1]
    from_port         = var.outbound_rules[count.index][2]
    to_port           = var.outbound_rules[count.index][3]
}

# ==================================================================================

output sg_id {
    value = aws_security_group.secgrp.id
}
