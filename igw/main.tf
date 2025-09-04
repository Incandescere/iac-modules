terraform {
  backend "s3" {}
}

variable vpc_id {
    type = string
}

variable default_rtb_id {
    type = string
}

variable name {
    type = string
}

variable project_name {
    type = string
}

# ==================================================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "igw-${var.project_name}-${var.name}"
  }
}

resource "aws_default_route_table" "drtb" {
  default_route_table_id = var.default_rtb_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


# ==================================================================================

output "igw_id" {
    value = aws_internet_gateway.igw.id
}
