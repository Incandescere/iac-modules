terraform {
  backend "s3" {}
}

variable name {
    type = string
}

variable vpc_id {
    type = string
}

variable subnets {
    type = list(string)
}

variable inbound_rules {
    type = list(list(string))
}

variable outbound_rules {
    type = list(list(string))
}

# in/outbound rules are of the format
# inoutbound_rule = [
#     ["action", "protocol", "cidr_1", "from_port", "to_port"], 
#     ["action", "protocol", "cidr_2", "from_port", "to_port"]
# ]

# ==================================================================================

resource "aws_network_acl" "nacl" {
    vpc_id = var.vpc_id
    tags = {
        Name = var.name
    }
}

resource "aws_network_acl_rule" "inbound_rules" {
    count           = length(var.inbound_rules)
    network_acl_id  = aws_network_acl.nacl.id
    rule_number     = 100+10*count.index
    egress          = false
    rule_action     = var.inbound_rules[count.index][0]
    protocol        = var.inbound_rules[count.index][1]
    # protocol        = -1
    cidr_block      = var.inbound_rules[count.index][2]
    from_port       = var.inbound_rules[count.index][3]
    to_port         = var.inbound_rules[count.index][4]
}

resource "aws_network_acl_rule" "outbound_rules" {
    count           = length(var.outbound_rules)
    network_acl_id  = aws_network_acl.nacl.id
    rule_number     = 100+10*count.index
    egress          = true
    rule_action     = var.outbound_rules[count.index][0]
    protocol        = var.outbound_rules[count.index][1]
    # protocol        = -1
    cidr_block      = var.outbound_rules[count.index][2]
    from_port       = var.outbound_rules[count.index][3]
    to_port         = var.outbound_rules[count.index][4]
}

resource "aws_network_acl_association" "nacl_to_subnet" {
    count           = length(var.subnets)
    network_acl_id  = aws_network_acl.nacl.id
    subnet_id       = var.subnets[count.index]
}

# ==================================================================================

output nacl_id {
    value = aws_network_acl.nacl.id
}
