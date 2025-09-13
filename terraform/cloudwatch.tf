# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 7

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-log-group"
  })
}

# CloudWatch Dashboard (Note: aws_cloudwatch_dashboard doesn't support tags)
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.app.name, "ClusterName", aws_ecs_cluster.main.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Service Metrics"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            [".", "TargetResponseTime", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Load Balancer Metrics"
          view   = "timeSeries"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.app.name}'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 100"
          region = var.aws_region
          title  = "Application Logs"
          view   = "table"
        }
      }
    ]
  })
}

# CloudWatch Metric Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${local.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"

  dimensions = {
    ServiceName = aws_ecs_service.app.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-high-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${local.name_prefix}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service memory utilization"

  dimensions = {
    ServiceName = aws_ecs_service.app.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-high-memory-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${local.name_prefix}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB response time"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-alb-response-time-alarm"
  })
}
