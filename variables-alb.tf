##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
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