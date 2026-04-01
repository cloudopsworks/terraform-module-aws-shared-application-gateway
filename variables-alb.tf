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
  description = <<-EOT
    (Optional) Whether the ALB should be internal or internet-facing.
    - `false`: Internet-facing ALB with public IP addresses (default)
    - `true`: Internal ALB accessible only within the VPC
    Default: false
  EOT
  type        = bool
  default     = false
  nullable    = false
}

variable "ip_address_type" {
  description = <<-EOT
    (Optional) The type of IP addresses used by the ALB.
    Possible values:
    - `ipv4`: IPv4 addresses only (default)
    - `dualstack`: Both IPv4 and IPv6 addresses
    Default: "ipv4"
  EOT
  type        = string
  default     = "ipv4"
  nullable    = false
}

variable "delete_protection" {
  description = <<-EOT
    (Optional) Enable or disable deletion protection for the ALB to prevent accidental deletion.
    - `true`: Deletion protection enabled (default)
    - `false`: Deletion protection disabled
    Default: true
  EOT
  type        = bool
  default     = true
  nullable    = false
}

variable "vpc_id" {
  description = <<-EOT
    (Required) The ID of the VPC where the ALB will be deployed.
    Example: "vpc-1234567890abcdef0"
  EOT
  type        = string
}

variable "private_subnet_ids" {
  description = <<-EOT
    (Optional) List of private subnet IDs for internal ALB deployment.
    Used when `is_internal = true`. Must span at least 2 availability zones.
    Example: ["subnet-abc123", "subnet-def456"]
    Default: []
  EOT
  type        = list(string)
  default     = []
  nullable    = false
}

variable "public_subnet_ids" {
  description = <<-EOT
    (Optional) List of public subnet IDs for internet-facing ALB deployment.
    Used when `is_internal = false`. Must span at least 2 availability zones.
    Example: ["subnet-123abc", "subnet-456def"]
    Default: []
  EOT
  type        = list(string)
  default     = []
  nullable    = false
}

variable "ssl_policy" {
  description = <<-EOT
    (Optional) The security policy to apply to HTTPS listeners.
    Common policies:
    - `ELBSecurityPolicy-TLS-1-2-2017-01`: TLS 1.2+ (default, recommended)
    - `ELBSecurityPolicy-TLS13-1-2-2021-06`: TLS 1.3 and 1.2
    - `ELBSecurityPolicy-FS-1-2-2019-08`: Forward secrecy only
    Default: "ELBSecurityPolicy-TLS-1-2-2017-01"
  EOT
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
  nullable    = false
}

variable "cross_zone_load_balancing" {
  description = <<-EOT
    (Optional) Enable cross-zone load balancing to distribute traffic evenly across all targets in all enabled AZs.
    - `true`: Enable cross-zone load balancing (default, recommended for HA)
    - `false`: Disable cross-zone load balancing
    Default: true
  EOT
  type        = bool
  default     = true
  nullable    = false
}

variable "extra_listeners" {
  description = <<-EOT
    (Optional) Additional listeners beyond the default HTTP (80) and HTTPS (443) listeners.

    Configuration structure (YAML format):
    ```yaml
    extra_listeners:
      - port: 8443                        # (Required) Port number for the listener
        ssl: true                         # (Optional) Enable SSL/TLS. Default: false
        mutual_authentication:            # (Optional) mTLS configuration for this listener
          mode: "verify"                  # (Required) "off", "verify", or "passthrough"
          trust_store_arn: "arn:aws:..."  # (Optional) Trust store ARN
          client_cert_expiry: false       # (Optional) Ignore cert expiry
    ```

    **Examples:**
    ```yaml
    # HTTP listener on custom port
    extra_listeners:
      - port: 8080
        ssl: false

    # HTTPS listener with mTLS
    extra_listeners:
      - port: 8443
        ssl: true
        mutual_authentication:
          mode: "verify"
          trust_store_arn: "arn:aws:elasticloadbalancing:us-east-1:123456789012:truststore/my-trust-store/abc123"
    ```

    Default: []
  EOT
  type        = any
  default     = []
  nullable    = false
}

variable "server_header_enabled" {
  description = <<-EOT
    (Optional) Enable or disable the server header in HTTP responses.
    - `true`: Include server header (may expose version information)
    - `false`: Suppress server header (default, recommended for security)
    Default: false
  EOT
  type        = bool
  default     = false
  nullable    = false
}

variable "mutual_authentication" {
  description = <<-EOT
    (Optional) Enable mutual TLS authentication for the default HTTPS listener (port 443).
    When configured, the ALB validates client certificates against a trust store before allowing connections.

    Configuration structure (YAML format):
    ```yaml
    mutual_authentication:
      mode: "verify"                      # (Required) Authentication mode
      trust_store_arn: "arn:aws:..."      # (Optional) ARN of the trust store containing client CA certificates
      client_cert_expiry: false           # (Optional) Ignore client certificate expiry. Default: false
    ```

    **Mode options:**
    - `off`: Disable mutual TLS authentication (default)
    - `verify`: Require and validate client certificates against the trust store
    - `passthrough`: Accept client certificates but don't validate them

    **Example:**
    ```yaml
    mutual_authentication:
      mode: "verify"
      trust_store_arn: "arn:aws:elasticloadbalancing:us-east-1:123456789012:truststore/my-trust-store/1234567890abcdef"
      client_cert_expiry: false
    ```

    Default: {} (disabled)
  EOT
  type        = any
  default     = {}
  nullable    = false
}

variable "default_action" {
  description = <<-EOT
    (Optional) Default action for extra listeners when no routing rules match.
    The HTTP listener (port 80) always redirects to HTTPS. This configures extra listeners.

    Configuration structure (YAML format):
    ```yaml
    default_action:
      type: "fixed-response"              # (Required) Action type: "fixed-response", "forward", or "redirect"

      # For fixed-response type:
      fixed:
        content_type: "application/json"  # (Optional) Response content type
        body: '{"error": "Not Allowed"}'  # (Optional) Response body
        status: "401"                     # (Optional) HTTP status code

      # For forward type:
      forward:
        target_groups:                    # (Required) List of target groups
          - arn: "arn:aws:..."            # (Required) Target group ARN
            weight: 100                   # (Optional) Weight for weighted routing
        stickiness:                       # (Optional) Sticky session configuration
          enabled: true                   # (Optional) Enable stickiness
          duration: 3600                  # (Optional) Duration in seconds

      # For redirect type:
      redirect:
        protocol: "HTTPS"                 # (Optional) Redirect protocol. Default: "#{protocol}"
        port: "443"                       # (Optional) Redirect port. Default: "#{port}"
        host: "#{host}"                   # (Optional) Redirect host
        path: "/#{path}"                  # (Optional) Redirect path
        query: "#{query}"                 # (Optional) Redirect query
        status_code: "HTTP_301"           # (Optional) Status code: HTTP_301 or HTTP_302
    ```

    **Examples:**
    ```yaml
    # Return fixed 401 response (default)
    default_action:
      type: "fixed-response"
      fixed:
        content_type: "application/json"
        body: '{"error": "Unauthorized"}'
        status: "401"

    # Forward to target group
    default_action:
      type: "forward"
      forward:
        target_groups:
          - arn: "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/abc123"
            weight: 100

    # Redirect to HTTPS
    default_action:
      type: "redirect"
      redirect:
        protocol: "HTTPS"
        port: "443"
        status_code: "HTTP_301"
    ```

    Default: {} (fixed-response with 401 status)
  EOT
  type        = any
  default     = {}
  nullable    = false
}

variable "web_acl_arn" {
  description = "(Optional) ARN of the AWS WAF Web ACL to associate with the ALB for application layer security."
  type        = string
  default     = ""
  nullable    = false
}