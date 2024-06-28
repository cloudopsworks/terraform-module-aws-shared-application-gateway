##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "access_logs" {
  type = map(object({
    enabled              = bool
    bucket               = string
    prefix               = optional(string, "")
    logs_retention_years = optional(number, 3)
    logs_archive_days    = optional(number, 30)
  }))
  description = "(required) Access logs configuration."
}
