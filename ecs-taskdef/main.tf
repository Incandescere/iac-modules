terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable execution_role_arn {
  type = string
}

variable task_role_arn {
  type = string
}

variable cpu {
  type = number
}

variable memory {
  type = number
}

variable os_family {
  type = string
}

variable cpu_architecture {
  type = string
}

variable td_template {
  default = ""
}

# ------------------------------------------

variable portName {
  type = string
}

variable containerName {
  type = string
}

variable image {
  type = string
}

variable loggroup {
  type = string
}

variable containerPort {
  type = number
}

# ==================================================================================

data "template_file" "ecstpl" {
  template = file(var.td_template)
  vars = {
    portName       = "port-${var.portName}"
    containerName  = "container-${var.containerName}"
    image          = var.image 
    loggroup       = var.loggroup
    containerPort  = var.containerPort
  }
}

//only supporting fargate for now
resource "aws_ecs_task_definition" "taskdef" {
  family                   = "td-${var.project_name}-${var.name}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu 
  memory                   = var.memory
  container_definitions    = data.template_file.ecstpl.rendered

  runtime_platform {
    operating_system_family = var.os_family
    cpu_architecture        = var.cpu_architecture
  }

}

# ==================================================================================

output arn {
  value = aws_ecs_task_definition.taskdef.arn
}

output id {
  value = aws_ecs_task_definition.taskdef.id
}
