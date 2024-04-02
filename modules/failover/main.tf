resource "aws_cloudwatch_metric_alarm" "target-unhealthy-count" {
  alarm_name          = "Unhealthy-Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    LoadBalancer = var.lb
    TargetGroup  = var.tg
  }
  alarm_actions      = [aws_sns_topic.tg-feed.arn]
}

resource "aws_sns_topic" "tg-feed" {
  name = "tg-feed"
}

resource "aws_sns_topic_subscription" "invoke_with_sns" {
  topic_arn = aws_sns_topic.tg-feed.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.failover.arn
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.tg-feed.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./modules/failover/failover.py"
  output_path = "lambda_function_payload.zip"
}
resource "aws_lambda_function" "failover" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "failover"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "failover.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.failover,
  ]

  runtime = "python3.12"
  logging_config {
    log_format = "Text"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_cloudwatch_log_group" "failover" {
  name              = "/aws/lambda/failover"
  retention_in_days = 14
}

data "aws_iam_policy_document" "failover_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "failover_logging" {
  name        = "failover_logging"
  path        = "/"
  description = "IAM policy for failover logging from a lambda"
  policy      = data.aws_iam_policy_document.failover_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.failover_logging.arn
}

data "aws_iam_policy_document" "failover_healthcheck" {
  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lb_healthcheck" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.failover_logging.arn
}