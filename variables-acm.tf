##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "default_ssl" {
  type = object({
    enabled           = bool
    cn                = string
    san               = optional(list(string), [])
    auto_validation   = optional(bool, false)
    validation_method = optional(string, "DNS")
    validation_domain = optional(string, "")
    validation_email  = optional(string, "")
  })
  default = {
    enabled           = false
    cn                = ""
    san               = []
    auto_validation   = false
    validation_method = "DNS"
    validation_domain = "example.com"
    validation_email  = ""
  }
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}