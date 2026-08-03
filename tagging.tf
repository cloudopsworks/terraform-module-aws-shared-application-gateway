##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

data "aws_network_interfaces" "this" {
  filter {
    name   = "requester-id"
    values = ["amazon-elb"]
  }
  filter {
    name   = "subnet-id"
    values = coalescelist(var.private_subnet_ids, var.public_subnet_ids)
  }
  filter {
    name   = "group-id"
    values = [aws_security_group.this.id]
  }
  depends_on = [aws_lb.this]
}

resource "aws_ec2_tag" "lb_eni" {
  for_each = merge([
    for sub in range(length(coalescelist(var.private_subnet_ids, var.public_subnet_ids))) : {
      for k, v in merge(local.all_tags, { Name = local.lb_name }) : "${sub}-${k}" => {
        index     = sub
        tag_key   = k
        tag_value = v
      }
    }
  ]...)
  resource_id = data.aws_network_interfaces.this.ids[each.value.index]
  key         = each.value.tag_key
  value       = each.value.tag_value
}