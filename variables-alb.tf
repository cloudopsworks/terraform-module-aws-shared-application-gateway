##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

# Defaults to external ALB
variable "is_internal" {
  type    = bool
  default = false
}

variable "ip_address_type" {
  type    = string
  default = "ipv4"
}

variable "delete_protection" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "cross_zone_load_balancing" {
  type    = bool
  default = true
}