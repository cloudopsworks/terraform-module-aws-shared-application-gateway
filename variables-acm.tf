##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "default_ssl" {
  description = "Configuration for the default SSL certificate to be used for the ALB listener. If enabled, the module will create a new ACM certificate with the specified Common Name (CN) and Subject Alternative Names (SANs). The certificate will be automatically validated using the specified validation method (DNS or Email) and validation domain/email. If auto_validation is set to true, the module will attempt to automatically validate the certificate using the provided information. If auto_validation is false, you will need to manually validate the certificate in ACM before it can be used by the ALB listener."
  type = object({
    enabled           = bool
    cn                = string
    san               = optional(list(string), [])
    auto_validation   = optional(bool, false)
    validation_method = optional(string, "DNS")
    validation_domain = optional(string, "")
    validation_email  = optional(string, "")
    dns_ttl           = optional(number, 300)
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
  nullable = false
}

variable "acm_certificate_arn" {
  description = "ARN of an existing ACM Certificate to use instead of creating a new one. If provided, the module will not create a new certificate and will use this ARN for the ALB listener. The certificate must be in the same region as the ALB and must be valid for the domain names used in the ALB listener rules."
  type     = string
  default  = ""
  nullable = false
}