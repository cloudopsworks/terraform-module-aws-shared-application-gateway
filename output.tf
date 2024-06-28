##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  value = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.this.zone_id
}

output "load_balancer_id" {
  value = aws_lb.this.id
}

output "load_balancer_security_group_id" {
  value = aws_security_group.this.id
}

output "load_balancer_security_group_name" {
  value = aws_security_group.this.name
}

output "load_balancer_http_listener_arn" {
  value = aws_lb_listener.this_http.arn
}

output "load_balancer_https_listener_arn" {
  value = aws_lb_listener.this_https.arn
}

output "default_acm_certificate_arn" {
  value = var.default_ssl.enabled ? aws_acm_certificate.default_cert[0].arn : ""
}