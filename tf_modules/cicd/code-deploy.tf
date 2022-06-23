resource "aws_codedeploy_app" "app" {
  count            = var.enabled ? 1 : 0
  compute_platform = "Server"
  name             = "${var.environment_name}-${var.app_name}-app"
}

resource "aws_codedeploy_deployment_group" "app-deployment-group-dev" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "dev-${var.app_name}-dg"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["dev-${var.app_name}-asg"]
  lifecycle {
    ignore_changes = [autoscaling_groups]
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "dev-${var.app_name}-tg"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events = ["DeploymentStart",
      "DeploymentSuccess",
      "DeploymentFailure",
      "DeploymentStop",
      "DeploymentRollback",
      "InstanceStart",
      "InstanceSuccess",
    "InstanceFailure"]
    trigger_name       = "dev-${var.app_name}-code-deploy-trigger-events"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}

resource "aws_codedeploy_deployment_group" "app-deployment-group-staging" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "staging-${var.app_name}-dg"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["staging-${var.app_name}-asg"]

  lifecycle {
    ignore_changes = [autoscaling_groups]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "staging-${var.app_name}-tg"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events = ["DeploymentStart",
      "DeploymentSuccess",
      "DeploymentFailure",
      "DeploymentStop",
      "DeploymentRollback",
      "InstanceStart",
      "InstanceSuccess",
    "InstanceFailure"]
    trigger_name       = "staging-${var.app_name}-code-deploy-trigger-events"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}

resource "aws_codedeploy_deployment_group" "app-deployment-group-prod" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "prod-${var.app_name}-dg"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["prod-${var.app_name}-asg"]

  lifecycle {
    ignore_changes = [autoscaling_groups]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "prod-${var.app_name}-tg"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events = ["DeploymentStart",
      "DeploymentSuccess",
      "DeploymentFailure",
      "DeploymentStop",
      "DeploymentRollback",
      "InstanceStart",
      "InstanceSuccess",
    "InstanceFailure"]
    trigger_name       = "prod-${var.app_name}-code-deploy-trigger-events"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}

# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "${var.environment_name}-codedeploy-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}