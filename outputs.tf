output "backend_services" {
  value = [for i, v in local.backend_services :
    {
      index_key = v.index_key
      id        = v.is_regional ? google_compute_region_backend_service.default[v.index_key].id : google_compute_backend_service.default[v.index_key].id
      type      = v.type
      region    = v.is_regional ? lookup(v, "region", "error") : "global"
      groups    = v.groups
    }
  ]
}
