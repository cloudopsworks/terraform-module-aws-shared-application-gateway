##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  access_logs = var.access_logs.enabled ? [
    {
      bucket               = var.access_logs.bucket_name
      prefix               = var.access_logs.logs_prefix
      logs_retention_years = var.access_logs.logs_retention_years
      logs_archive_days    = var.access_logs.logs_archive_days
    }
  ] : []
}
# ALB resource
resource "aws_lb" "this" {
  name                             = format("alb-%s", local.system_name_short)
  internal                         = var.is_internal
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.this.id]
  subnets                          = var.is_internal ? var.private_subnet_ids : var.public_subnet_ids
  ip_address_type                  = var.ip_address_type
  preserve_host_header             = true
  xff_header_processing_mode       = "append"
  enable_deletion_protection       = var.delete_protection
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = local.access_logs
    content {
      enabled = access_logs.value.enabled
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
    }
  }

  tags = merge(
    local.all_tags,
    {
      Name = format("alb-%s", local.system_name)
    }
  )
  lifecycle {
    ignore_changes = [
      security_groups,
      tags["elasticbeanstalk:shared-elb-environment-count"]
    ]
  }
}

# Listeners
resource "aws_lb_listener" "this_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = merge(
    local.all_tags,
    {
      Name = format("alb-%s-http", local.system_name_short)
    }
  )
}

resource "aws_lb_listener" "this_https" {
  depends_on = [
    aws_acm_certificate_validation.default_cert
  ]
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.default_cert[0].arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{\"error\": \"Not Allowed\"}"
      status_code  = "401"
    }
  }
  tags = merge(
    local.all_tags,
    {
      Name = format("alb-%s-https", local.system_name_short)
    }
  )
}

# resource "aws_ec2_tag" "default_action_80" {
#   for_each    = local.all_tags
#   resource_id = aws_lb_listener.this_http.default_action[0].id
#   key         = each.key
#   value       = each.value
# }
#
# resource "aws_ec2_tag" "default_action_443" {
#   for_each    = local.all_tags
#   resource_id = aws_lb_listener.this_https.default_action[0].id
#   key         = each.key
#   value       = each.value
# }