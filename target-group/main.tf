terraform {
  backend "s3" {}
}

variable name {
    type = string
}

variable project_name {
    type = string
}


variable vpc_id {
    type = string
}

variable tg_port {
    type = number
}

variable tg_protocol {
    type = string
}

variable ip_addrs {
    type = list(string)
}

# ==================================================================================

resource "aws_lb_target_group" "tg" {
  name        = "tg-${var.project_name}-${var.name}"
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "tgattach" {
    count            = length(var.ip_addrs)
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = var.ip_addrs[count.index]
    port             = var.tg_port
}

# ==================================================================================

output tg_id {
    value = aws_lb_target_group.tg.id
}

output tg_arn {
    value = aws_lb_target_group.tg.arn
}