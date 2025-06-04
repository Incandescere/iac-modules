terraform {
  backend "s3" {}
}

variable subnets {
  type = list(string)
}

variable eips {
  type = list(string)
}

# ==================================================================================

resource "aws_nat_gateway" "ngws" {
  count             = length(var.subnets)
  # connectivity_type = "private"
  subnet_id         = var.subnets[count.index]
  allocation_id     = var.eips[count.index]
}

# ==================================================================================

output ngw_ids {
  value = aws_nat_gateway.ngws[*].id
}
