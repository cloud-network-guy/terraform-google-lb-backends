# Backend Buckets
locals {
  _backend_buckets = [for i, v in var.backends :
    {
      create     = coalesce(v.create, true)
      project_id = coalesce(v.project_id, var.project_id)
      name       = lower(trimspace(coalesce(v.name, "backend-bucket-{$v.bucket_name}")))
      enable_cdn = coalesce(v.enable_cdn, true) # This is probably static content, so why not?
    } if lower(coalesce(v.type, "unknown")) == "bucket" || v.bucket_name != null
  ]
  backend_buckets = [for i, v in local._backend_buckets :
    merge(v, {
      bucket_name = coalesce(v.bucket_name, v.name, "bucket-${v.name}")
      description = coalesce(v.description, "Backend Bucket '${v.name}'")
      index_key   = "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}
resource "google_compute_backend_bucket" "default" {
  for_each    = { for i, v in local.backend_buckets : v.index_key => v }
  project     = each.value.project_id
  name        = each.value.name
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn
}

# Backend Services
locals {
  _backend_services = [for i, v in var.backends :
    merge(v, {
      create           = coalesce(v.create, true)
      project_id       = coalesce(v.project_id, var.project_id)
      name             = lower(trimspace(coalesce(v.name, "${var.name_prefix}-${i}")))
      region           = lower(trimspace(v.region))
      groups           = coalesce(v.groups, [])
      health_checks    = v.healthcheck != null ? [v.healthcheck] : coalesce(v.healthchecks, [])
      session_affinity = coalesce(v.session_affinity, var.session_affinity, "NONE")
      logging          = coalesce(v.logging, var.logging, false)
      timeout_sec      = coalesce(v.timeout, var.timeout, 30)
    })
  ]
  __backend_services = [for i, v in local._backend_services :
    merge(v, {
      description = trimspace(coalesce(v.description, "Backend Service '${v.name}'"))
      is_regional = v.region != null ? true : false
      is_internal = true
      is_managed  = false
      instance_groups = [for ig in coalesce(v.instance_groups, []) :
        {
          project_id = coalesce(ig.project_id, v.project_id)
          id         = ig.id
          name       = ig.name
          zone       = ig.zone
        }
      ]
    })
  ]
  ___backend_services = [for i, v in local.__backend_services :
    merge(v, {
      protocol  = "TCP"
      hc_prefix = "projects/${v.project_id}/${v.is_regional ? "regions/${v.region}" : "global"}/healthChecks"
      instance_groups = length(v.groups) > 0 ? [] : [for ig in v.instance_groups :
        try(coalesce(
          ig.id,
          ig.zone != null && ig.name != null ? "projects/${ig.project_id}/zones/${ig.zone}/instanceGroups/${ig.name}" : null,
        ), [])
      ],
    })
  ]
  ____backend_services = flatten([for i, v in local.___backend_services :
    [v.is_managed ? merge(v, {
      locality_lb_policy    = upper(coalesce(v.locality_lb_policy, "ROUND_ROBIN"))
      capacity_scaler       = coalesce(v.capacity_scaler, 1.0)
      max_utilization       = coalesce(v.max_utilization, 0.8)
      max_rate_per_instance = v.max_rate_per_instance
    }) : v]
  ])
  backend_services = [for i, v in local.____backend_services :
    merge(v, {
      #network                         = v.is_global ? null : coalesce(v.network, "default")
      #subnet                          = v.is_global ? null : coalesce(v.subnet, "default")
      balancing_mode                  = v.protocol == "TCP" ? "CONNECTION" : "UTILIZATION"
      load_balancing_scheme           = v.is_internal ? "INTERNAL" : "EXTERNAL"
      connection_draining_timeout_sec = coalesce(v.connection_draining_timeout, 300)
      max_connections                 = v.protocol == "TCP" && !v.is_regional ? coalesce(v.max_connections, 8192) : null
      groups                          = flatten(coalesce(v.groups, v.instance_groups))
      health_checks = flatten([for health_check in v.health_checks :
        [startswith(health_check, "projects/") ? health_check : "${v.hc_prefix}/${health_check}"]
      ])
      index_key = v.is_regional ? "${v.project_id}/${v.region}/${v.name}" : "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}

# Generate a null resource for each Backend, so that an existing one is completely destroyed before attempting create
resource "null_resource" "backend_services" {
  for_each = { for i, v in local.backend_services : v.index_key => true }
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  for_each                        = { for i, v in local.backend_services : v.index_key => v if !v.is_regional }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = each.value.load_balancing_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.protocol
  port_name                       = each.value.port_name
  timeout_sec                     = each.value.timeout_sec
  health_checks                   = each.value.health_checks
  session_affinity                = each.value.session_affinity
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  custom_request_headers          = each.value.custom_request_headers
  custom_response_headers         = each.value.custom_response_headers
  security_policy                 = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.balancing_mode
      max_rate_per_instance = each.value.max_rate_per_instance
      max_utilization       = each.value.max_utilization
      max_connections       = each.value.max_connections
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  /*
  dynamic "iap" {
    for_each = each.value.use_iap ? [true] : []
    content {
      oauth2_client_id     = google_iap_client.default[each.key].client_id
      oauth2_client_secret = google_iap_client.default[each.key].secret
    }
  }
  */
  enable_cdn = each.value.enable_cdn
  dynamic "cdn_policy" {
    for_each = each.value.enable_cdn == true ? [true] : []
    content {
      cache_mode                   = each.value.cdn_cache_mode
      signed_url_cache_max_age_sec = 3600
      default_ttl                  = each.value.cdn_default_ttl
      client_ttl                   = each.value.cdn_client_ttl
      max_ttl                      = each.value.cdn_max_ttl
      negative_caching             = false
      cache_key_policy {
        include_host           = true
        include_protocol       = true
        include_query_string   = true
        query_string_blacklist = []
        query_string_whitelist = []
      }
    }
  }
  depends_on = [null_resource.backend_services]
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  for_each                        = { for i, v in local.backend_services : v.index_key => v if v.is_regional }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = each.value.load_balancing_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.protocol
  port_name                       = each.value.port_name
  timeout_sec                     = each.value.timeout_sec
  health_checks                   = each.value.health_checks
  session_affinity                = each.value.session_affinity
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.balancing_mode
      max_rate_per_instance = each.value.max_rate_per_instance
      max_utilization       = each.value.max_utilization
      max_connections       = each.value.max_connections
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  region     = each.value.region
  depends_on = [null_resource.backend_services]
}
