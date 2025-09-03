terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable aws_managed_policy_arns {
  type    = list(string)
  default = []
} 

# ==================================================================================

resource "aws_iam_policy" "iam-policy" {
  name        = "iam-policy-${var.project_name}-${var.name}"
  path        = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:*",
          "ssm:*",
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

//both need assume role policy, as they are assumed by ecs-tasks
resource "aws_iam_role" "iam-role" {
  name = "iam-role-${var.project_name}-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role-policy-attach" {
  role       = aws_iam_role.iam-role.name
  policy_arn = aws_iam_policy.iam-policy.arn
}

resource "aws_iam_role_policy_attachment" "aws-policy-attach" {
  count      = length(var.aws_managed_policy_arns)
  role       = aws_iam_role.iam-role.name
  policy_arn = var.aws_managed_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "iam-profile" {
  name = "iam-profile-${var.project_name}-${var.name}"
  role = aws_iam_role.iam-role.name
}

# ==================================================================================

output arn {
  value = aws_iam_role.iam-role.arn
}

output id {
  value = aws_iam_role.iam-role.id
}
