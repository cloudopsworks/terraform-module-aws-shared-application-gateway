##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  lb_name = format("alb-%s", local.system_name_short)
}

# ALB resource
resource "aws_lb" "this" {
  name                             = local.lb_name
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
    for_each = var.access_logs.enabled ? [1] : []
    content {
      enabled = var.access_logs.enabled
      bucket  = var.access_logs.bucket_name
      prefix  = "${var.access_logs.logs_prefix}/access"
    }
  }

  dynamic "connection_logs" {
    for_each = var.access_logs.enabled ? [1] : []
    content {
      enabled = var.access_logs.enabled
      bucket  = var.access_logs.bucket_name
      prefix  = "${var.access_logs.logs_prefix}/connections"
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
  load_balancer_arn                    = aws_lb.this.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = var.server_header_enabled

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
  load_balancer_arn                    = aws_lb.this.arn
  port                                 = 443
  protocol                             = "HTTPS"
  ssl_policy                           = var.ssl_policy
  certificate_arn                      = var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.default_cert[0].arn
  routing_http_response_server_enabled = var.server_header_enabled
  dynamic "mutual_authentication" {
    for_each = length(var.mutual_authentication) > 0 ? [1] : []
    content {
      mode                             = var.mutual_authentication.mode
      trust_store_arn                  = try(var.mutual_authentication.trust_store_arn, null)
      ignore_client_certificate_expiry = try(var.mutual_authentication.client_cert_expiry, null)
    }
  }
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

# Extra listeners
resource "aws_lb_listener" "extra_https" {
  for_each = {
    for listener in var.extra_listeners : "port-${listener.port}" => listener
  }
  depends_on = [
    aws_acm_certificate_validation.default_cert
  ]
  load_balancer_arn                    = aws_lb.this.arn
  port                                 = each.value.port
  protocol                             = try(each.value.ssl, false) ? "HTTPS" : "HTTP"
  ssl_policy                           = try(each.value.ssl, false) ? var.ssl_policy : null
  certificate_arn                      = try(each.value.ssl, false) ? (var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.default_cert[0].arn) : null
  routing_http_response_server_enabled = var.server_header_enabled
  dynamic "mutual_authentication" {
    for_each = length(try(each.value.mutual_authentication, {})) > 0 ? [1] : []
    content {
      mode                             = each.value.mutual_authentication.mode
      trust_store_arn                  = try(each.value.mutual_authentication.trust_store_arn, null)
      ignore_client_certificate_expiry = try(each.value.mutual_authentication.client_cert_expiry, null)
    }
  }
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
      Name = format("alb-%s-%s", local.system_name_short, try(each.value.ssl, false) ? "https" : "http")
    }
  )
}

data "aws_network_interfaces" "this" {
  filter {
    name   = "requester-id"
    values = ["amazon-elb"]
  }
  filter {
    name   = "subnet-id"
    values = coalescelist(var.private_subnet_ids, var.public_subnet_ids)
  }
  filter {
    name   = "group-id"
    values = [aws_security_group.this.id]
  }
  depends_on = [aws_lb.this]
}

resource "aws_ec2_tag" "lb_eni" {
  for_each = merge([
    for sub in range(length(coalescelist(var.private_subnet_ids, var.public_subnet_ids))) : {
      for k, v in merge(local.all_tags, { Name = local.lb_name }) : "${sub}-${k}" => {
        index     = sub
        tag_key   = k
        tag_value = v
      }
    }
  ]...)
  resource_id = data.aws_network_interfaces.this.ids[each.value.index]
  key         = each.value.tag_key
  value       = each.value.tag_value
}