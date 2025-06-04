terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable cluster_id {
  type = string
}

variable task_definition_arn {
  type = string
}

variable desired_count {
  type = number
}

variable subnets_list {
  type = list(string)
}

variable secgrps_list {
  type = list(string)
}

variable svc_conn_namespace {
  type = string
}

variable svc_conn_port {
  type = number
}

# ----------------------------------------------------------------------------------
// for load balancing block
//if tg_arn present, takes the above container name/port to assoociate w specified tg
variable tg_arn_list {
  type = list(string)
  default = []
}

# ----------------------------------------------------------------------------------
// for autoscaling blocks 

variable clusterName {
  type = string 
}

# Metrics available 
# https://docs.aws.amazon.com/autoscaling/application/userguide/monitoring-cloudwatch.html#predefined-metrics
variable scalingMetric {
  type = string
  default = "ECSServiceAverageCPUUtilization"
}

variable scalingTargetValue {
  type = number
  default = 50
}

variable scaleInCD {
  type = number
  default = 30 
}

variable scaleOutCD {
  type = number
  default = 30 
}

variable min_capacity {
  type = number
  default = 1
}

variable max_capacity {
  type = number
  default = 2
}

# ==================================================================================

resource "aws_ecs_service" "ecs-svc" {
  name            = "${var.name}-ecs-svc"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnets_list
    security_groups  = var.secgrps_list
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.svc_conn_namespace

    service {
      port_name       = var.name
      discovery_name  = "cloudmap-${var.name}"
      client_alias {
        dns_name = "svc-conn-${var.name}"
        port     = var.svc_conn_port
      }
    }
  }

  dynamic "load_balancer" {
    for_each = var.tg_arn_list
    content {
      target_group_arn  = var.tg_arn_list[0]
      container_name    = "${var.name}-container"
      container_port    = var.svc_conn_port
    }
  }
}

# ----------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.clusterName}/${var.name}-ecs-svc"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scaling_policy" {
  name               = "avgcpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.scalingMetric 
    }

    target_value       = var.scalingTargetValue
    scale_in_cooldown  = var.scaleInCD
    scale_out_cooldown = var.scaleOutCD 
  }
}

# ==================================================================================

output id {
  value = aws_ecs_service.ecs-svc.id
}
