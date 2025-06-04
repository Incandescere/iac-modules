terraform {
  backend "s3" {}
}

variable subnets_list {
    type = list(list(string))
}

variable vpc_id {
    type = string
}

# ==================================================================================

resource "aws_subnet" "subnets" {
    count = length(var.subnets_list)
    vpc_id = var.vpc_id
    cidr_block = var.subnets_list[count.index][1]
    availability_zone = var.subnets_list[count.index][2]

    tags = {
        Name = var.subnets_list[count.index][0]
    }
}

# ==================================================================================

output "subnet_ids" {
    value = aws_subnet.subnets.*.id
}

output "subnet_arns" {
    value = aws_subnet.subnets.*.arn
}
