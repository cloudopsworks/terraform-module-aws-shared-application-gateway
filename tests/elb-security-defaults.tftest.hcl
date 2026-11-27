mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/alb-test/1234567890abcdef"
    }
  }
}

variables {
  org = {
    organization_name = "example"
    organization_unit = "platform"
    environment_type  = "test"
    environment_name  = "test"
  }
  vpc_id              = "vpc-01234567890123456"
  public_subnet_ids   = ["subnet-01234567890123456", "subnet-01234567890123457"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
}

run "security_defaults" {
  command = plan

  variables {
    extra_listeners = [
      { port = 8080 },
      { port = 8081, ssl = false, default_action = {} },
      { port = 8443, ssl = true, default_action = {} },
      { port = 9443, ssl = true, default_action = null },
    ]
  }

  assert {
    condition     = aws_lb.this.drop_invalid_header_fields
    error_message = "The ALB should drop invalid HTTP headers by default."
  }

  assert {
    condition = (
      aws_lb_listener.this_http.protocol == "HTTP" &&
      one(aws_lb_listener.this_http.default_action).type == "redirect" &&
      one(one(aws_lb_listener.this_http.default_action).redirect).protocol == "HTTPS" &&
      one(one(aws_lb_listener.this_http.default_action).redirect).port == "443" &&
      one(one(aws_lb_listener.this_http.default_action).redirect).status_code == "HTTP_301"
    )
    error_message = "The primary HTTP listener should redirect to HTTPS on port 443."
  }

  assert {
    condition = alltrue([
      for listener in [
        aws_lb_listener.this_https,
        aws_lb_listener.extra_https["port-8443"],
        aws_lb_listener.extra_https["port-9443"],
        ] : (
        listener.protocol == "HTTPS" &&
        listener.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
      )
    ])
    error_message = "The primary and additional HTTPS listeners should use the ELB.17 TLS policy."
  }

  assert {
    condition = alltrue([
      for listener in concat([aws_lb_listener.this_https], values(aws_lb_listener.extra_https)) : try(
        one(listener.default_action).type == "fixed-response" &&
        one(one(listener.default_action).fixed_response).status_code == "401" &&
        one(one(listener.default_action).fixed_response).content_type == "application/json" &&
        one(one(listener.default_action).fixed_response).message_body == "{\"error\": \"Not Allowed\"}",
        false
      )
    ])
    error_message = "The primary HTTPS and additional listeners should return the v1.4.1 JSON 401 response for empty actions."
  }
}

run "explicit_overrides" {
  command = plan

  variables {
    drop_invalid_header_fields = false
    ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"
    default_action = {
      type  = "fixed-response"
      fixed = { status = "403" }
    }
    extra_listeners = [
      { port = 8080 },
      {
        port = 8081
        default_action = {
          type = "redirect"
          redirect = {
            protocol    = "HTTPS"
            port        = "8443"
            status_code = "HTTP_302"
          }
        }
      },
      {
        port = 8082
        type = "forward"
        forward = {
          target_groups = [{
            arn    = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/legacy/1234567890abcdef"
            weight = 100
          }]
        }
      },
      { port = 8443, ssl = true },
      {
        port  = 9443
        ssl   = true
        type  = "fixed-response"
        fixed = { status = "405" }
        default_action = {
          type  = "fixed-response"
          fixed = { status = "404" }
        }
      },
    ]
  }

  assert {
    condition     = !aws_lb.this.drop_invalid_header_fields
    error_message = "An explicit setting should disable invalid HTTP header dropping."
  }

  assert {
    condition = alltrue([
      for listener in [
        aws_lb_listener.this_https,
        aws_lb_listener.extra_https["port-8443"],
        aws_lb_listener.extra_https["port-9443"],
      ] : listener.ssl_policy == "ELBSecurityPolicy-TLS-1-2-2017-01"
    ])
    error_message = "The explicit SSL policy should apply to every HTTPS listener."
  }

  assert {
    condition = (
      one(one(aws_lb_listener.this_https.default_action).fixed_response).status_code == "403" &&
      one(one(aws_lb_listener.extra_https["port-8443"].default_action).fixed_response).status_code == "401" &&
      one(one(aws_lb_listener.extra_https["port-9443"].default_action).fixed_response).status_code == "404"
    )
    error_message = "The module action should apply to the primary HTTPS listener, and a nested extra listener action should take precedence over inline fields."
  }

  assert {
    condition = (
      try(one(one(aws_lb_listener.extra_https["port-8080"].default_action).fixed_response).status_code, null) == "401" &&
      try(one(one(aws_lb_listener.extra_https["port-8081"].default_action).redirect).port, null) == "8443" &&
      try(one(one(aws_lb_listener.extra_https["port-8081"].default_action).redirect).status_code, null) == "HTTP_302"
    )
    error_message = "Extra HTTP listeners should use the fixed 401 response by default and honor an explicit redirect."
  }

  assert {
    condition = (
      one(aws_lb_listener.extra_https["port-8082"].default_action).type == "forward" &&
      one(one(one(aws_lb_listener.extra_https["port-8082"].default_action).forward).target_group).arn == "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/legacy/1234567890abcdef"
    )
    error_message = "An existing top-level forward action should still forward to its configured target group."
  }
}

run "extra_listeners_do_not_inherit_primary_redirect" {
  command = plan

  variables {
    default_action = {
      type     = "redirect"
      redirect = { host = "www.example.com", protocol = "HTTPS", port = "443" }
    }
    extra_listeners = [
      { port = 8080, ssl = false },
      { port = 8443, ssl = true },
      {
        port = 9443
        ssl  = true
        default_action = {
          type     = "redirect"
          redirect = { protocol = "HTTPS", port = "443", status_code = "HTTP_302" }
        }
      }
    ]
  }

  assert {
    condition = (
      aws_lb_listener.extra_https["port-8443"].protocol == "HTTPS" &&
      one(aws_lb_listener.extra_https["port-8443"].default_action).type == "fixed-response" &&
      try(one(one(aws_lb_listener.extra_https["port-8443"].default_action).fixed_response).status_code, null) == "401"
    )
    error_message = "An extra HTTPS listener without an action should return the fixed 401 response."
  }

  assert {
    condition = (
      one(one(aws_lb_listener.this_https.default_action).redirect).host == "www.example.com" &&
      try(one(one(aws_lb_listener.extra_https["port-8080"].default_action).fixed_response).status_code, null) == "401" &&
      one(one(aws_lb_listener.extra_https["port-9443"].default_action).redirect).port == "443" &&
      one(one(aws_lb_listener.extra_https["port-9443"].default_action).redirect).status_code == "HTTP_302"
    )
    error_message = "The primary and explicitly configured extra listener redirects should coexist with an extra HTTP listener using the fixed 401 response."
  }
}
