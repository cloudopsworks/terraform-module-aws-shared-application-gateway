##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "access_logs" {
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
  description = "(required) Access logs configuration."
}
