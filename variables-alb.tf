##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Defaults to external ALB
variable "is_internal" {
  description = "Whether the ALB should be internal or internet-facing. If not specified, it will default to false (internet-facing)."
  type     = bool
  default  = false
  nullable = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the ALB. Valid values are ipv4 and dualstack. If not specified, it will default to ipv4."
  type     = string
  default  = "ipv4"
  nullable = false
}

variable "delete_protection" {
  description = "Enable or disable deletion protection for the ALB. If not specified, it will default to true (enabled)."
  type     = bool
  default  = true
  nullable = false
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the ALB. This variable is required and does not have a default value."
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with the ALB. If not specified, it will default to an empty list (no subnets)."
  type     = list(string)
  default  = []
  nullable = false
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to associate with the ALB. If not specified, it will default to an empty list (no subnets)."
  type     = list(string)
  default  = []
  nullable = false
}

variable "ssl_policy" {
  description = "The security policy to apply to the HTTPS listener. If not specified, it will default to ELBSecurityPolicy-TLS-1-2-2017-01."
  type     = string
  default  = "ELBSecurityPolicy-TLS-1-2-2017-01"
  nullable = false
}

variable "cross_zone_load_balancing" {
  description = "Enable or disable cross-zone load balancing. If not specified, it will default to true (enabled)."
  type     = bool
  default  = true
  nullable = false
}

variable "extra_listeners" {
  description = "Additional listeners to create on the ALB. Each listener should be defined as an object with the following properties: protocol (string), port (number), ssl_policy (string, optional), certificate_arn (string, optional), default_action (object). If not specified, it will default to an empty list (no additional listeners)."
  type     = any
  default  = []
  nullable = false
}

variable "server_header_enabled" {
  description = "Enable or disable the server header in HTTP responses. If not specified, it will default to false (disabled)."
  type     = bool
  default  = false
  nullable = false
}

variable "mutual_authentication" {
  description = "Enable mutual TLS authentication"
  type        = any
  default     = {}
  nullable    = false
}

variable "default_action" {
  description = "Default action for the HTTP listener. If not specified, it will default to a redirect to HTTPS."
  type        = any
  default     = {}
  nullable    = false
}