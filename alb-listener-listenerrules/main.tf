terraform {
  backend "s3" {}
}

variable name {
    type = string
}

variable project_name {
    type = string
}

variable subnets {
    type = list(string)
}

variable secgrps {
    type = list(string)
}

variable lb_listener_port {
    type = number
}

variable lb_listener_protocol {
    type = string
}

variable listener_rules {
    type = list(any)
}

# currently only supports path_pattern
# listener_rules = [
#     [["cond1", "cond2"], tg1],
#     [["cond3", "cond4"], tg2]
# ]

variable log_bucket {
  type = string
  default = ""
}

# ==================================================================================
resource "aws_lb" "alb" {
  name               = "alb-${var.project_name}-${var.name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.secgrps
  subnets            = var.subnets

  enable_deletion_protection = true

  access_logs {
    bucket  = var.log_bucket
    enabled = var.log_bucket == "" ? false : true
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "222"
    }
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  count = length(var.listener_rules)
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100+10*count.index

  condition {
    path_pattern {
      values = var.listener_rules[count.index][0]
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.listener_rules[count.index][1]
  }
}

# ==================================================================================

output id {
  value = aws_lb.alb.id
}

output arn {
  value = aws_lb.alb.arn
}

# "->": requires

# alb -> secgrp 
# alb -> listener
# listener -> listener_rule
# listener_rule -> targetgrp
# targetgrp -> tgattach 