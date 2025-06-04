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

# ==================================================================================

resource "aws_route_table" "rtbs" {
  count  = length(var.subnets)
  vpc_id = var.vpc_id 
}

resource "aws_route_table_association" "rtb-assoc" {
  count  = length(var.subnets)
  subnet_id      = var.subnets[count.index]
  route_table_id = aws_route_table.rtbs[count.index].id
}

# ==================================================================================

output arn {
  value = aws_route_table.rtbs[*].arn
}

output id {
  value = aws_route_table.rtbs[*].id
}
