##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "access_logs" {
  type = map(object({
    enabled              = bool
    bucket               = string
    logs_prefix          = optional(string, "")
    logs_retention_years = optional(number, 3)
    logs_archive_days    = optional(number, 30)
  }))
  default = {
    access_logs = {
      enabled              = false
      bucket               = ""
      logs_prefix          = ""
      logs_retention_years = 3
      logs_archive_days    = 30
    }
  }
  description = "(required) Access logs configuration."
}
