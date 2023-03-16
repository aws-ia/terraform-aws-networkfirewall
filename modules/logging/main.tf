# --- modules/logging/main.tf ---
locals {
  log_type_lookup = {
    alert_log_destination = "ALERT",
    flow_log_destination  = "FLOW"
  }

  log_destination_lookup = {
    s3_bucket        = "S3",
    cloudwatch_logs  = "CloudWatchLogs",
    kinesis_firehose = "KinesisDataFirehose"
  }

  log_destination_params = {
    alert_log_destination = {
      s3_bucket = {
        bucketName = try(var.logging_configuration.alert_log_destination.s3_bucket.bucketName, null)
        prefix     = try(var.logging_configuration.alert_log_destination.s3_bucket.logPrefix, null)
      }
      cloudwatch_logs = {
        logGroup = try(var.logging_configuration.alert_log_destination.cloudwatch_logs.logGroupName, null)
      }
      kinesis_firehose = {
        deliveryStream = try(var.logging_configuration.alert_log_destination.kinesis_firehose.deliveryStreamName, null)
      }
    }

    flow_log_destination = {
      s3_bucket = {
        bucketName = try(var.logging_configuration.flow_log_destination.s3_bucket.bucketName, null)
        prefix     = try(var.logging_configuration.flow_log_destination.s3_bucket.logPrefix, null)
      }
      cloudwatch_logs = {
        logGroup = try(var.logging_configuration.flow_log_destination.cloudwatch_logs.logGroupName, null)
      }
      kinesis_firehose = {
        deliveryStream = try(var.logging_configuration.flow_log_destination.kinesis_firehose.deliveryStreamName, null)
      }
    }

  }
}

resource "aws_networkfirewall_logging_configuration" "anfw_logs" {
  firewall_arn = var.firewall_arn
  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.logging_configuration
      content {
        log_type             = local.log_type_lookup[log_destination_config.key]
        log_destination_type = local.log_destination_lookup[keys(log_destination_config.value)[0]]
        log_destination      = local.log_destination_params[log_destination_config.key][keys(log_destination_config.value)[0]]
      }
    }
  }
}
