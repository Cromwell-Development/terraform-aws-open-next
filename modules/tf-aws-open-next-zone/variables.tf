variable "prefix" {
  description = "A prefix which will be attached to the resource name to ensure resources are random"
  type        = string
  default     = null
}

variable "suffix" {
  description = "A suffix which will be attached to the resource name to ensure resources are random"
  type        = string
  default     = null
}

variable "s3_folder_prefix" {
  description = "An optional folder to store files under"
  type        = string
  default     = null
}

variable "zone_suffix" {
  description = "An optional zone suffix to add to the assets and cache folder to allow files to be loaded correctly"
  type        = string
  default     = null
}

variable "folder_path" {
  description = "The path to the open next artifacts"
  type        = string
}

variable "s3_exclusion_regex" {
  description = "A regex of files to exclude from the s3 copy"
  type        = string
  default     = null
}

variable "function_architecture" {
  description = "The default instruction set architecture for the lambda functions. This can be overridden for each function"
  type        = string
  default     = "arm64"
}

variable "iam" {
  description = "The default IAM configuration. This can be overridden for each function"
  type = object({
    path                 = optional(string, "/")
    permissions_boundary = optional(string)
  })
  default = {}
}

variable "cloudwatch_log" {
  description = "The default cloudwatch log group. This can be overridden for each function"
  type = object({
    retention_in_days = number
  })
  default = {
    retention_in_days = 7
  }
}

variable "vpc" {
  description = "The default VPC configuration for the lambda resources. This can be overridden for each function"
  type = object({
    security_group_ids = list(string),
    subnet_ids         = list(string)
  })
  default = null
}

variable "aliases" {
  description = "The production and staging aliases to use"
  type = object({
    production = string
    staging    = string
  })
  default = null
}

variable "cache_control_immutable_assets_regex" {
  description = "Regex to set public,max-age=31536000,immutable on immutable resources"
  type        = string
  default     = "^.*(\\.next)$"
}

variable "content_types" {
  description = "The MIME type mapping and default for artefacts generated by Open Next"
  type = object({
    mapping = optional(map(string), {
      "svg"  = "image/svg+xml",
      "js"   = "application/javascript",
      "css"  = "text/css",
      "html" = "text/html"
    })
    default = optional(string, "binary/octet-stream")
  })
  default = {}
}

variable "warmer_function" {
  description = "Configuration for the warmer function"
  type = object({
    enabled = optional(bool, false)
    warm_staging = optional(object({
      enabled     = optional(bool, false)
      concurrency = optional(number)
    }))
    function_code = optional(object({
      handler = optional(string, "index.handler")
      zip = optional(object({
        path = string
        hash = string
      }))
      s3 = optional(object({
        bucket         = string
        key            = string
        object_version = optional(string)
      }))
    }))
    runtime                          = optional(string, "nodejs20.x")
    concurrency                      = optional(number, 20)
    timeout                          = optional(number, 15 * 60) // 15 minutes
    memory_size                      = optional(number, 1024)
    function_architecture            = optional(string)
    schedule                         = optional(string, "rate(5 minutes)")
    additional_environment_variables = optional(map(string), {})
    additional_iam_policies = optional(list(object({
      name   = string,
      arn    = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
    iam = optional(object({
      path                 = optional(string)
      permissions_boundary = optional(string)
    }))
    cloudwatch_log = optional(object({
      retention_in_days = number
    }))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
  })
  default = {}
}

variable "server_function" {
  description = "Configuration for the server function"
  type = object({
    function_code = optional(object({
      handler = optional(string, "index.handler")
      zip = optional(object({
        path = string
        hash = string
      }))
      s3 = optional(object({
        bucket         = string
        key            = string
        object_version = optional(string)
      }))
    }))
    runtime                          = optional(string, "nodejs20.x")
    backend_deployment_type          = optional(string, "REGIONAL_LAMBDA")
    timeout                          = optional(number, 10)
    memory_size                      = optional(number, 1024)
    function_architecture            = optional(string)
    additional_environment_variables = optional(map(string), {})
    additional_iam_policies = optional(list(object({
      name   = string,
      arn    = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
    iam = optional(object({
      path                 = optional(string)
      permissions_boundary = optional(string)
    }))
    cloudwatch_log = optional(object({
      retention_in_days = number
    }))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
  })
  default = {}

  validation {
    condition     = contains(["REGIONAL_LAMBDA_WITH_AUTH_LAMBDA", "REGIONAL_LAMBDA", "EDGE_LAMBDA"], var.server_function.backend_deployment_type)
    error_message = "The server function backend deployment type can be one of REGIONAL_LAMBDA_WITH_AUTH_LAMBDA, REGIONAL_LAMBDA or EDGE_LAMBDA"
  }
}

variable "image_optimisation_function" {
  description = "Configuration for the image optimisation function"
  type = object({
    create = optional(bool, true)
    function_code = optional(object({
      handler = optional(string, "index.handler")
      zip = optional(object({
        path = string
        hash = string
      }))
      s3 = optional(object({
        bucket         = string
        key            = string
        object_version = optional(string)
      }))
    }))
    runtime                          = optional(string, "nodejs20.x")
    backend_deployment_type          = optional(string, "REGIONAL_LAMBDA")
    timeout                          = optional(number, 25)
    memory_size                      = optional(number, 1536)
    additional_environment_variables = optional(map(string), {})
    function_architecture            = optional(string)
    additional_iam_policies = optional(list(object({
      name   = string,
      arn    = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
    iam = optional(object({
      path                 = optional(string)
      permissions_boundary = optional(string)
    }))
    cloudwatch_log = optional(object({
      retention_in_days = number
    }))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
  })
  default = {}

  validation {
    condition     = contains(["REGIONAL_LAMBDA_WITH_AUTH_LAMBDA", "REGIONAL_LAMBDA"], var.image_optimisation_function.backend_deployment_type)
    error_message = "The server function backend deployment type can be one of REGIONAL_LAMBDA_WITH_AUTH_LAMBDA or REGIONAL_LAMBDA"
  }
}

variable "revalidation_function" {
  description = "Configuration for the revalidation function"
  type = object({
    function_code = optional(object({
      handler = optional(string, "index.handler")
      zip = optional(object({
        path = string
        hash = string
      }))
      s3 = optional(object({
        bucket         = string
        key            = string
        object_version = optional(string)
      }))
    }))
    runtime                          = optional(string, "nodejs20.x")
    timeout                          = optional(number, 25)
    memory_size                      = optional(number, 1536)
    additional_environment_variables = optional(map(string), {})
    function_architecture            = optional(string)
    additional_iam_policies = optional(list(object({
      name   = string,
      arn    = optional(string)
      policy = optional(string)
    })), [])
    vpc = optional(object({
      security_group_ids = list(string),
      subnet_ids         = list(string)
    }))
    iam = optional(object({
      path                 = optional(string)
      permissions_boundary = optional(string)
    }))
    cloudwatch_log = optional(object({
      retention_in_days = number
    }))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
  })
  default = {}
}

variable "tag_mapping_db" {
  description = "Configuration for the ISR tag mapping database"
  type = object({
    deployment     = optional(string, "CREATE")
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    read_capacity  = optional(number)
    write_capacity = optional(number)
    revalidate_gsi = optional(object({
      read_capacity  = optional(number)
      write_capacity = optional(number)
    }), {})
  })
  default = {}
}

variable "website_bucket" {
  description = "Configuration for the website S3 bucket"
  type = object({
    deployment           = optional(string, "CREATE")
    create_bucket_policy = optional(bool, true)
    force_destroy        = optional(bool, false)
    arn                  = optional(string)
    region               = optional(string)
    name                 = optional(string)
    domain_name          = optional(string)
  })
  default = {}
}

variable "distribution" {
  description = "Configuration for the CloudFront distribution. NOTE: please use ID as ARN for the cache policy is deprecated"
  type = object({
    deployment   = optional(string, "CREATE")
    enabled      = optional(bool, true)
    ipv6_enabled = optional(bool, true)
    http_version = optional(string, "http2")
    price_class  = optional(string, "PriceClass_100")
    geo_restrictions = optional(object({
      type      = optional(string, "none"),
      locations = optional(list(string), [])
    }), {})
    x_forwarded_host_function = optional(object({
      runtime = optional(string)
      code    = optional(string)
    }), {})
    auth_function = optional(object({
      deployment    = optional(string, "NONE")
      qualified_arn = optional(string)
      function_code = optional(object({
        handler = optional(string, "index.handler")
        zip = optional(object({
          path = string
          hash = string
        }))
        s3 = optional(object({
          bucket         = string
          key            = string
          object_version = optional(string)
        }))
      }))
      runtime     = optional(string, "nodejs20.x")
      timeout     = optional(number, 10)
      memory_size = optional(number, 256)
      additional_iam_policies = optional(list(object({
        name   = string,
        arn    = optional(string)
        policy = optional(string)
      })), [])
      iam = optional(object({
        path                 = optional(string)
        permissions_boundary = optional(string)
      }))
      cloudwatch_log = optional(object({
        retention_in_days = number
      }))
      timeouts = optional(object({
        create = optional(string)
        update = optional(string)
        delete = optional(string)
      }), {})
    }), {})
    cache_policy = optional(object({
      deployment            = optional(string, "CREATE")
      arn                   = optional(string)
      id                    = optional(string)
      default_ttl           = optional(number, 0)
      max_ttl               = optional(number, 31536000)
      min_ttl               = optional(number, 0)
      cookie_behavior       = optional(string, "all")
      header_behavior       = optional(string, "whitelist")
      header_items          = optional(list(string), ["accept", "rsc", "next-router-prefetch", "next-router-state-tree", "next-url"])
      query_string_behavior = optional(string, "all")
    }), {})
  })
  default = {}
}

variable "behaviours" {
  description = "Override the default behaviour config"
  type = object({
    custom_error_responses = optional(object({
      path_overrides = optional(map(object({
        allowed_methods          = optional(list(string))
        cached_methods           = optional(list(string))
        cache_policy_id          = optional(string)
        origin_request_policy_id = optional(string)
        compress                 = optional(bool)
        viewer_protocol_policy   = optional(string)
        viewer_request = optional(object({
          type         = string
          arn          = string
          include_body = optional(bool)
        }))
        viewer_response = optional(object({
          type = string
          arn  = string
        }))
        origin_request = optional(object({
          arn          = string
          include_body = bool
        }))
        origin_response = optional(object({
          arn = string
        }))
      })))
      allowed_methods          = optional(list(string))
      cached_methods           = optional(list(string))
      cache_policy_id          = optional(string)
      origin_request_policy_id = optional(string)
      compress                 = optional(bool)
      viewer_protocol_policy   = optional(string)
      viewer_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      viewer_response = optional(object({
        type = string
        arn  = string
      }))
      origin_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      origin_response = optional(object({
        type = string
        arn  = string
      }))
    }))
    static_assets = optional(object({
      paths            = optional(list(string))
      additional_paths = optional(list(string))
      path_overrides = optional(map(object({
        allowed_methods          = optional(list(string))
        cached_methods           = optional(list(string))
        cache_policy_id          = optional(string)
        origin_request_policy_id = optional(string)
        compress                 = optional(bool)
        viewer_protocol_policy   = optional(string)
        viewer_request = optional(object({
          type         = string
          arn          = string
          include_body = optional(bool)
        }))
        viewer_response = optional(object({
          type = string
          arn  = string
        }))
        origin_request = optional(object({
          arn          = string
          include_body = bool
        }))
        origin_response = optional(object({
          arn = string
        }))
      })))
      allowed_methods          = optional(list(string))
      cached_methods           = optional(list(string))
      cache_policy_id          = optional(string)
      origin_request_policy_id = optional(string)
      compress                 = optional(bool)
      viewer_protocol_policy   = optional(string)
      viewer_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      viewer_response = optional(object({
        type = string
        arn  = string
      }))
      origin_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      origin_response = optional(object({
        type = string
        arn  = string
      }))
    }))
    server = optional(object({
      paths = optional(list(string))
      path_overrides = optional(map(object({
        allowed_methods          = optional(list(string))
        cached_methods           = optional(list(string))
        cache_policy_id          = optional(string)
        origin_request_policy_id = optional(string)
        compress                 = optional(bool)
        viewer_protocol_policy   = optional(string)
        viewer_request = optional(object({
          type         = string
          arn          = string
          include_body = optional(bool)
        }))
        viewer_response = optional(object({
          type = string
          arn  = string
        }))
        origin_request = optional(object({
          arn          = string
          include_body = bool
        }))
        origin_response = optional(object({
          arn = string
        }))
      })))
      allowed_methods          = optional(list(string))
      cached_methods           = optional(list(string))
      cache_policy_id          = optional(string)
      origin_request_policy_id = optional(string)
      compress                 = optional(bool)
      viewer_protocol_policy   = optional(string)
      viewer_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      viewer_response = optional(object({
        type = string
        arn  = string
      }))
      origin_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      origin_response = optional(object({
        type = string
        arn  = string
      }))
    }))
    image_optimisation = optional(object({
      paths = optional(list(string))
      path_overrides = optional(map(object({
        allowed_methods          = optional(list(string))
        cached_methods           = optional(list(string))
        cache_policy_id          = optional(string)
        origin_request_policy_id = optional(string)
        compress                 = optional(bool)
        viewer_protocol_policy   = optional(string)
        viewer_request = optional(object({
          type         = string
          arn          = string
          include_body = optional(bool)
        }))
        viewer_response = optional(object({
          type = string
          arn  = string
        }))
        origin_request = optional(object({
          arn          = string
          include_body = bool
        }))
        origin_response = optional(object({
          arn = string
        }))
      })))
      allowed_methods          = optional(list(string))
      cached_methods           = optional(list(string))
      cache_policy_id          = optional(string)
      origin_request_policy_id = optional(string)
      compress                 = optional(bool)
      viewer_protocol_policy   = optional(string)
      viewer_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      viewer_response = optional(object({
        type = string
        arn  = string
      }))
      origin_request = optional(object({
        type         = string
        arn          = string
        include_body = optional(bool)
      }))
      origin_response = optional(object({
        type = string
        arn  = string
      }))
    }))
  })
  default = {}
}

variable "waf" {
  description = "Configuration for the CloudFront distribution WAF. For enforce basic auth, to protect the secret value, the encoded string has been marked as sensitive. I would make this configurable to allow it to be marked as sensitive or not however Terraform panics when you use the sensitive function as part of a ternary. If you need to see all rules, see this discussion https://discuss.hashicorp.com/t/how-to-show-sensitive-values/24076/4"
  type = object({
    deployment = optional(string, "NONE")
    web_acl_id = optional(string)
    aws_managed_rules = optional(list(object({
      priority              = optional(number)
      name                  = string
      aws_managed_rule_name = string
      })), [{
      name                  = "amazon-ip-reputation-list"
      aws_managed_rule_name = "AWSManagedRulesAmazonIpReputationList"
      }, {
      name                  = "common-rule-set"
      aws_managed_rule_name = "AWSManagedRulesCommonRuleSet"
      }, {
      name                  = "known-bad-inputs"
      aws_managed_rule_name = "AWSManagedRulesKnownBadInputsRuleSet"
    }])
    rate_limiting = optional(object({
      enabled = optional(bool, false)
      limits = optional(list(object({
        priority         = optional(number)
        rule_name_suffix = optional(string)
        limit            = optional(number, 1000)
        action           = optional(string, "BLOCK")
        geo_match_scope  = optional(list(string))
      })), [])
    }), {})
    sqli = optional(object({
      enabled  = optional(bool, false)
      priority = optional(number)
    }), {})
    account_takeover_protection = optional(object({
      enabled              = optional(bool, false)
      priority             = optional(number)
      login_path           = string
      enable_regex_in_path = optional(bool)
      request_inspection = optional(object({
        username_field_identifier = string
        password_field_identifier = string
        payload_type              = string
      }))
      response_inspection = optional(object({
        failure_codes = list(string)
        success_codes = list(string)
      }))
    }))
    account_creation_fraud_prevention = optional(object({
      enabled                = optional(bool, false)
      priority               = optional(number)
      creation_path          = string
      registration_page_path = string
      enable_regex_in_path   = optional(bool)
      request_inspection = optional(object({
        email_field_identifier    = string
        username_field_identifier = string
        password_field_identifier = string
        payload_type              = string
      }))
      response_inspection = optional(object({
        failure_codes = list(string)
        success_codes = list(string)
      }))
    }))
    enforce_basic_auth = optional(object({
      enabled       = optional(bool, false)
      priority      = optional(number)
      response_code = optional(number, 401)
      response_header = optional(object({
        name  = optional(string, "WWW-Authenticate")
        value = optional(string, "Basic realm=\"Requires basic auth\"")
      }), {})
      header_name = optional(string, "authorization")
      credentials = optional(object({
        username          = string
        password          = string
        mark_as_sensitive = optional(bool, true)
      }))
      ip_address_restrictions = optional(list(object({
        action = optional(string, "BYPASS")
        arn    = optional(string)
        name   = optional(string)
      })))
    }))
    additional_rules = optional(list(object({
      enabled  = optional(bool, false)
      priority = optional(number)
      name     = string
      action   = optional(string, "COUNT")
      block_action = optional(object({
        response_code = number
        response_header = optional(object({
          name  = string
          value = string
        }))
        custom_response_body_key = optional(string)
      }))
      ip_address_restrictions = list(object({
        action = optional(string, "BYPASS")
        arn    = optional(string)
        name   = optional(string)
      }))
    })))
    default_action = optional(object({
      action = optional(string, "ALLOW")
      block_action = optional(object({
        response_code = number
        response_header = optional(object({
          name  = string
          value = string
        }))
        custom_response_body_key = optional(string)
      }))
    }))
    ip_addresses = optional(map(object({
      description        = optional(string)
      ip_address_version = string
      addresses          = list(string)
    })))
    custom_response_bodies = optional(list(object({
      key          = string
      content      = string
      content_type = string
    })))
  })
  default = {}
}

variable "domain_config" {
  description = "Configuration for CloudFront distribution domain"
  type = object({
    evaluate_target_health = optional(bool, true)
    sub_domain             = optional(string)
    hosted_zones = list(object({
      name         = string
      id           = optional(string)
      private_zone = optional(bool, false)
    }))
    create_route53_entries = optional(bool, true)
    viewer_certificate = optional(object({
      acm_certificate_arn      = string
      ssl_support_method       = optional(string, "sni-only")
      minimum_protocol_version = optional(string, "TLSv1.2_2021")
    }))
  })
  default = null
}

variable "continuous_deployment" {
  description = "Configuration for continuous deployment config for CloudFront"
  type = object({
    use        = optional(bool, true)
    deployment = optional(string, "NONE")
    traffic_config = optional(object({
      header = optional(object({
        name  = string
        value = string
      }))
      weight = optional(object({
        percentage = number
        session_stickiness = optional(object({
          idle_ttl    = number
          maximum_ttl = number
        }))
      }))
    }))
  })
  default = {}
}

variable "custom_error_responses" {
  description = "Allow custom error responses to be set on the distributions"
  type = list(object({
    error_code            = string
    error_caching_min_ttl = optional(number)
    response_code         = optional(string)
    response_page = optional(object({
      source      = string
      path_prefix = string
    }))
  }))
  default = []
}

variable "scripts" {
  description = "Modify default script behaviours"
  type = object({
    interpreter                      = optional(string)
    additional_environment_variables = optional(map(string))
    delete_folder_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    file_sync_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    invalidate_cloudfront_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    promote_distribution_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    remove_continuous_deployment_policy_id_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    save_item_to_dynamo_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    update_alias_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
    update_parameter_script = optional(object({
      interpreter                      = optional(string)
      path                             = optional(string)
      additional_environment_variables = optional(map(string))
    }))
  })
  default = {}
}