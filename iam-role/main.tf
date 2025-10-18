terraform {
  backend "s3" {}
}

variable name {
  type = string
}

variable project_name {
  type = string
}

variable policy_service_list {
  type    = list(string)
  default = []
} 

variable aws_managed_policy_arns {
  type    = list(string)
  default = []
} 

variable services_assuming_role {
  type    = list(string)
  default = [] // ["ecs-tasks.amazonaws.com"]
}

variable "oidc_assuming_role" {
  type = list(object({
    provider_arn = string      # arn of oidc idp
    repo         = string      # e.g., "myorg/myrepo"
    branch       = string      # e.g., "main" or "*" for all branches
  }))
  default = []
}

# ==================================================================================

resource "aws_iam_policy" "iam-policy" {
  count = length(var.policy_service_list) == 0 ? 0 : 1
  name        = "iam-policy-${var.project_name}-${var.name}"
  path        = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          for svc in var.policy_service_list: "${svc}"
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
    Statement = concat(
      # AWS services
      [
        for svc in var.services_assuming_role : {
          Effect = "Allow"
          Principal = { Service = svc }
          Action = "sts:AssumeRole"
        }
      ],
      # OIDC providers with repo/branch restrictions
      [
        for oidc in var.oidc_assuming_role : {
          Effect    = "Allow"
          Principal = { Federated = oidc.provider_arn }
          Action    = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:${oidc.repo}:ref:refs/heads/${oidc.branch}"
            }
            StringEquals = {
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
            }
          }
        }
      ]
    )
  })
}

resource "aws_iam_role_policy_attachment" "role-policy-attach" {
  count      = length(aws_iam_policy.iam-policy)
  role       = aws_iam_role.iam-role.name
  policy_arn = aws_iam_policy.iam-policy[count.index].arn
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
