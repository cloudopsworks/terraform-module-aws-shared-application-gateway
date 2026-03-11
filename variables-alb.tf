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
  type     = bool
  default  = false
  nullable = false
}

variable "ip_address_type" {
  type     = string
  default  = "ipv4"
  nullable = false
}

variable "delete_protection" {
  type     = bool
  default  = true
  nullable = false
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "public_subnet_ids" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "ssl_policy" {
  type     = string
  default  = "ELBSecurityPolicy-TLS-1-2-2017-01"
  nullable = false
}

variable "cross_zone_load_balancing" {
  type     = bool
  default  = true
  nullable = false
}

variable "extra_listeners" {
  type     = any
  default  = []
  nullable = false
}

variable "server_header_enabled" {
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