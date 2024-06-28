##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_route53_zone" "this" {
  count = var.default_ssl.enabled && var.default_ssl.auto_validation && var.default_ssl.validation_method == "DNS" ? 1 : 0
  name  = var.default_ssl.validation_domain
}
