data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "./modules/iam_role"
  name       = "cstaskexecution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
      "ec2:CreateTags",
      "appmesh:*",
      "xray:*"
    ]
    resources = ["*"]
  }
}

module "ecs_task_role" {
  source     = "./modules/iam_role"
  name       = "ecstask"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task.json
}
