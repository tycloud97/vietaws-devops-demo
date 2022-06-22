resource "aws_codedeploy_app" "app" {
  count            = var.enabled ? 1 : 0
  compute_platform = "Server"
  name             = "${var.app_name}-App"
}

resource "aws_codedeploy_deployment_group" "app_deployment_group" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "${var.app_name}-DG"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["dev-asg"]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "dev-tg"
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
    trigger_name       = "${var.app_name}-CodeDeploy-TriggerEvents"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }

  
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 1
    }

    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"
    }

    terminate_blue_instances_on_deployment_success {
      action = "KEEP_ALIVE"
    }
  }
}

resource "aws_codedeploy_deployment_group" "app_deployment_group_staging" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "${var.app_name}-DG-staging"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["dev-asg"]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "dev-tg"
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
    trigger_name       = "${var.app_name}-CodeDeploy-TriggerEvents"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }
}

resource "aws_codedeploy_deployment_group" "app_deployment_group_prod" {
  count                  = var.enabled ? 1 : 0
  app_name               = aws_codedeploy_app.app[0].name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_group_name  = "${var.app_name}-DG-prod"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  autoscaling_groups     = ["dev-asg"]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = "dev-tg"
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
    trigger_name       = "${var.app_name}-CodeDeploy-TriggerEvents"
    trigger_target_arn = aws_sns_topic.code_deploy.arn
  }
}