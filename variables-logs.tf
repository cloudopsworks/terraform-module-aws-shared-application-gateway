##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "access_logs" {
  description = <<-EOT
    (Optional) Configuration for ALB access and connection logs stored in S3.
    When enabled, the ALB will write detailed request logs and connection logs to the specified S3 bucket.

    Configuration structure (YAML format):
    ```yaml
    access_logs:
      enabled: true                       # (Required) Enable access and connection logging. Default: false
      bucket_name: "my-alb-logs"          # (Required when enabled) S3 bucket name for logs
      logs_prefix: "production/alb"       # (Optional) S3 prefix for organizing logs. Default: ""
      logs_retention_years: 3             # (Optional) Years to retain logs. Default: 3
      logs_archive_days: 30               # (Optional) Days before archiving to Glacier. Default: 30
    ```

    **S3 Bucket Requirements:**
    - Bucket must be in the same region as the ALB
    - Bucket must have appropriate bucket policy to allow ELB service to write logs
    - Bucket policy example:
      ```json
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticloadbalancing.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::my-alb-logs/*"
      }
      ```

    **Log Types:**
    - **Access Logs**: Stored at `s3://<bucket>/<prefix>/access/`
      - Contains detailed information about requests sent to the ALB
      - Includes client IP, request path, response codes, latency, etc.
    - **Connection Logs**: Stored at `s3://<bucket>/<prefix>/connections/`
      - Contains TLS handshake details and connection-level information
      - Includes cipher suite, TLS version, connection time, etc.

    **Example:**
    ```yaml
    access_logs:
      enabled: true
      bucket_name: "my-company-alb-logs"
      logs_prefix: "production/us-east-1"
      logs_retention_years: 7
      logs_archive_days: 90
    ```

    Default: { enabled = false }
  EOT
  type = object({
    enabled              = bool
    bucket_name          = string
    logs_prefix          = optional(string, "")
    logs_retention_years = optional(number, 3)
    logs_archive_days    = optional(number, 30)
  })
  default = {
    enabled              = false
    bucket_name          = ""
    logs_prefix          = ""
    logs_retention_years = 3
    logs_archive_days    = 30
  }
}
