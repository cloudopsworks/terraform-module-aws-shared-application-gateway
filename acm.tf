##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  dvos = var.default_ssl.enabled ? aws_acm_certificate.default_cert[0].domain_validation_options : []
}
resource "aws_acm_certificate" "default_cert" {
  count                     = var.default_ssl.enabled ? 1 : 0
  domain_name               = var.default_ssl.cn
  validation_method         = var.default_ssl.validation_method
  subject_alternative_names = var.default_ssl.san

  tags = merge(
    local.all_tags,
    {
      "Description" = "Default Certificate for alb-${local.system_name}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default_cert" {
  for_each = {
    for dvo in local.dvos : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    } if endswith(dvo.domain_name, var.default_ssl.validation_domain) && var.default_ssl.auto_validation && var.default_ssl.validation_method == "DNS"
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.value]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[0].id
}

resource "aws_acm_certificate_validation" "default_cert" {
  count           = var.default_ssl.enabled && var.default_ssl.auto_validation && var.default_ssl.validation_method == "DNS" ? 1 : 0
  certificate_arn = aws_acm_certificate.default_cert[count.index].arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.default_cert[count.index].domain_validation_options :
    dvo.resource_record_name
  ]

  timeouts {
    create = "60m"
  }
}
