##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "default_ssl" {
  description = <<-EOT
    (Optional) Configuration for automatically creating an ACM certificate for the ALB listener.
    When enabled, creates a new certificate with automatic or manual validation.

    Configuration structure (YAML format):
    ```yaml
    default_ssl:
      enabled: true                       # (Required) Enable auto-generated certificate. Default: false
      cn: "example.com"                   # (Required when enabled) Common Name (primary domain)
      san:                                # (Optional) Subject Alternative Names (additional domains)
        - "www.example.com"
        - "api.example.com"
      auto_validation: true               # (Optional) Automatically validate via DNS. Default: false
      validation_method: "DNS"            # (Optional) Validation method: "DNS" or "EMAIL". Default: "DNS"
      validation_domain: "example.com"    # (Required for auto DNS validation) Route53 hosted zone domain
      validation_email: ""                # (Optional) Email for EMAIL validation method
      dns_ttl: 300                        # (Optional) TTL for DNS validation records. Default: 300
    ```

    **Validation Methods:**
    - `DNS`: Requires creating DNS records (CNAME) in your domain's hosted zone
      - With `auto_validation = true`: Module creates Route53 records automatically (requires `validation_domain`)
      - With `auto_validation = false`: You must manually create the validation records
    - `EMAIL`: AWS sends validation email to domain contacts (requires manual action)

    **Examples:**
    ```yaml
    # Automatic DNS validation (recommended)
    default_ssl:
      enabled: true
      cn: "app.example.com"
      san:
        - "www.app.example.com"
      auto_validation: true
      validation_method: "DNS"
      validation_domain: "example.com"

    # Manual DNS validation
    default_ssl:
      enabled: true
      cn: "app.example.com"
      auto_validation: false
      validation_method: "DNS"

    # Email validation
    default_ssl:
      enabled: true
      cn: "app.example.com"
      auto_validation: false
      validation_method: "EMAIL"
    ```

    **Note:** If you already have an ACM certificate, use `acm_certificate_arn` instead of this variable.

    Default: { enabled = false }
  EOT
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
    dns_ttl           = 300
  }
  nullable = false
}

variable "acm_certificate_arn" {
  description = <<-EOT
    (Optional) ARN of an existing ACM Certificate to use for HTTPS listeners.
    When provided, the module will not create a new certificate.

    **Requirements:**
    - Certificate must be in the same AWS region as the ALB
    - Certificate must be valid for the domain names used in ALB routing
    - Certificate must be in "Issued" status

    **Example:**
    ```yaml
    acm_certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    ```

    **Note:** This takes precedence over `default_ssl`. If both are provided, this ARN will be used.

    Default: "" (use auto-generated certificate from `default_ssl` if enabled)
  EOT
  type        = string
  default     = ""
  nullable    = false
}