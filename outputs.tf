##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "load_balancer_name" {
  description = "Name assigned to the Application Load Balancer."
  value       = local.lb_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer, used for WAF associations and AWS Shield."
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer, used as the target of Route53 ALIAS records."
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Route53 hosted zone ID of the Application Load Balancer, required by Route53 ALIAS records."
  value       = aws_lb.this.zone_id
}

output "load_balancer_id" {
  description = "ID of the Application Load Balancer resource."
  value       = aws_lb.this.id
}

output "load_balancer_security_group_id" {
  description = "ID of the security group attached to the Application Load Balancer, used to grant access to backend services."
  value       = aws_security_group.this.id
}

output "load_balancer_security_group_name" {
  description = "Name of the security group attached to the Application Load Balancer."
  value       = aws_security_group.this.name
}

output "load_balancer_http_listener_arn" {
  description = "ARN of the default HTTP listener on port 80, used to attach listener rules."
  value       = aws_lb_listener.this_http.arn
}

output "load_balancer_https_listener_arn" {
  description = "ARN of the default HTTPS listener on port 443, used to attach listener rules."
  value       = aws_lb_listener.this_https.arn
}

output "default_acm_certificate_arn" {
  description = "ARN of the ACM certificate created by this module, empty when `default_ssl.enabled` is false."
  value       = var.default_ssl.enabled ? aws_acm_certificate.default_cert[0].arn : ""
}
