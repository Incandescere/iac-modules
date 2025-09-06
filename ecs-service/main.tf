terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable container_port {
  type = number
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

variable sc_enabled {
  type = bool
}

variable svc_conn_namespace {
  type = string
  default = ""
}

variable svc_conn_port {
  type = number
  default = 1
}

variable public_cluster {
  type = bool
  default = false
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
  name            = "ecs-svc-${var.project_name}-${var.name}"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnets_list
    security_groups  = var.secgrps_list
    assign_public_ip = var.public_cluster
  }
  
  dynamic "service_connect_configuration" {
    for_each = var.sc_enabled ? [1] : []
    content {
      enabled = var.sc_enabled
      namespace = var.svc_conn_namespace
      service {
        port_name      = "port-${var.project_name}-${var.name}"
        discovery_name = "cloudmap-${var.name}"

        client_alias {
          dns_name = "svc-conn-${var.name}"
          port     = var.svc_conn_port
        }
      }
    }
  }

  dynamic "load_balancer" {
    for_each = var.tg_arn_list
    content {
      target_group_arn  = var.tg_arn_list[0]
      container_name  = "container-${var.project_name}-${var.name}"
      container_port    = var.container_port
    }
  }
}

# ----------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.clusterName}/ecs-svc-${var.project_name}-${var.name}"
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
