##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Security groups for ALB
resource "aws_security_group" "this" {
  name        = "alb-${local.system_name}-sg"
  description = "Shared/Central Load Balancer security group for ${local.system_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.all_tags,
    {
      Name = "alb-sg-${local.system_name}"
    }
  )

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "sg_all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic by default"
  tags              = local.all_tags
}

resource "aws_vpc_security_group_ingress_rule" "sg_80" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound traffic on port 80"
  tags              = local.all_tags
}

resource "aws_vpc_security_group_ingress_rule" "sg_443" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound traffic on port 443"
  tags              = local.all_tags
}

# Extra listeners only get an ingress rule when the listener declares `allow_cidrs`.
# Each (port, cidr) pair becomes its own rule because aws_vpc_security_group_ingress_rule
# accepts a single CIDR. IPv6 CIDRs are detected by the presence of ":".
# "0.0.0.0/0" / "::/0" are not recommended and are warned about (see check below) but not blocked.
locals {
  extra_listener_ingress = {
    for pair in flatten([
      for listener in var.extra_listeners : [
        for cidr in try(listener.allow_cidrs, []) : {
          port = listener.port
          cidr = cidr
          ipv6 = strcontains(cidr, ":")
        }
      ]
    ]) : "port-${pair.port}-${replace(replace(pair.cidr, "/", "_"), ":", "-")}" => pair
  }
  extra_listener_open_cidrs = [
    for pair in values(local.extra_listener_ingress) : "${pair.port} (${pair.cidr})"
    if contains(["0.0.0.0/0", "::/0"], pair.cidr)
  ]
}

resource "aws_vpc_security_group_ingress_rule" "sg_extra_https" {
  for_each          = local.extra_listener_ingress
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_ipv4         = each.value.ipv6 ? null : each.value.cidr
  cidr_ipv6         = each.value.ipv6 ? each.value.cidr : null
  description       = "Allow inbound traffic on port ${each.value.port} from ${each.value.cidr}"
  tags              = local.all_tags
}

check "extra_listeners_open_to_world" {
  assert {
    condition     = length(local.extra_listener_open_cidrs) == 0
    error_message = "extra_listeners allow_cidrs opens port(s) ${join(", ", local.extra_listener_open_cidrs)} to the world. Restrict allow_cidrs to trusted ranges instead of 0.0.0.0/0 or ::/0."
  }
}
