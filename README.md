# Google Cloud Platform Load Balancers

Supported Types:
- External Global HTTP(S) non-classic
- External Global HTTP(S) classic
- External Regional HTTP(S)
- Internal HTTP(S)
- Internal TCP/UDP
- Global TCP Proxy
- Global SSL Proxy

## Resources 

- [google_cloud_run_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service)
- [google_cloud_run_service_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam)
- [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)
- [google_compute_backend_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket)
- [google_compute_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service)
- [google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule)
- [google_compute_global_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address)
- [google_compute_global_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule)
- [google_compute_global_network_endpoint](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint)
- [google_compute_global_network_endpoint_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint_group)
- [google_compute_instance_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group)
- [google_compute_instance_group_named_port](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_named_port)
- [google_compute_managed_ssl_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate)
- [google_compute_region_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service)
- [google_compute_region_network_endpoint_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group)
- [google_compute_region_ssl_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_certificate)
- [google_compute_region_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_policy)
- [google_compute_region_target_http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy)
- [google_compute_region_target_https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_https_proxy)
- [google_compute_region_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map)
- [google_compute_service_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment)
- [google_compute_ssl_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)
- [google_compute_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy)
- [google_compute_target_http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy)
- [google_compute_target_https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy)
- [google_compute_target_tcp_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_tcp_proxy)
- [google_compute_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map)
- [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)
- [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)
- [tls_self_signed_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert)

## Inputs 

### Required Inputs

| Name            | Description                        | Type     |
|-----------------|------------------------------------|----------|
| project\_id     | Project ID of the GCP project      | `string` | 

### Optional Inputs

| Name               | Description                                      | Type     | Default |
|--------------------|--------------------------------------------------|----------|---------|
| name_prefix        | Name Prefix for components of this Load Balancer | `string` | n/a     |
| address            | IP address to use for the load balancer frontend | `string` | n/a     |
| backends     | List of LB backends.  See structure below    | `list(object)` | [] | 
| default_backend    | Key of the default backend to use                | `string` |         |
| default_service_id | ID of a pre-existing backend service or bucket   | `string` | n/a     | 
| backend_timeout    | Default timeout for all backends used by this LB | `number` | 30      |
| cloudarmor_policy  | CloudArmor Policy for all backends               | `string` | n/a |

#### Notes

- If `name_prefix` is no provided, a random 5 character string will be used
- Default Backend timeout can be overridden on individual backends with the `timeout` attribute
- Timeout behavior depends on the load balancer type.  For HTTP(S), it is a max time for the request/response to be fully processed.

### Inputs relevant to Regional Load Balancers

| Name        | Description       | Type      | Default | 
|-------------|-------------------|-----------|---------|
| region      | GCP Region Name   | `string`  | null    |

#### Notes

- There is no default region for the LB itself, but Regional backend resources default to `us-central1`

### Inputs relevant to all External Load Balancers

| Name         | Description                                               | Type     | Default |
|--------------|-----------------------------------------------------------|----------|---------|
| enable_ipv4  | Create an IPv4 address for the forwarding rule            | `bool`   | true    |
| enable_ipv6  | Create an IPv6 address for the forwarding rule            | `bool`   | false   |
| ipv4_address | Existing IPv4 Address to use for the forwarding rule      | `string` | n/a     |
| ipv6_address | Existing IPv6 Address to use for the fowarding rule       | `string` | n/a     |

#### Notes

- If IP addresses are not specified, new static IPs will be created and used
- `enable_ipv6` is only supported on external global Load Balancers

### Inputs relevant to all Internal Load Balancers

| Name               | Description                                              | Type     | Default |
|--------------------|----------------------------------------------------------|----------|---------|
| network_name       | VPC Network Name for LB Listener                         | `string` | default |
| subnet_name        | Name of the Subnet                                       | `string` | n/a     |
| network_project_id | If using Shared VPC, Project ID of the Host              | `string` | n/a     |

#### Notes

- `network_name` is also required for Regional external HTTP(S) load balancer if VPC network is not "default"

### Inputs relevant to HTTP(S) & SSL Proxy Load Balancers

| Name           | Description                                        | Type           | Default |
|----------------|----------------------------------------------------|----------------|---------|
| ssl_certs      | Map of SSL Certs & Keys to Import                  | `map(object)`  | null    |
| use_gmc        | Use Google-Managed SSL Certs                       | `bool`         | false   |
| use_ssc        | Use a Self-Signed Certificate                      | `string`       | true    |
| domains        | For Google-Managed or Self-Signed, list of domains | `list(string)` | n/a     |
| key_algorithm  | When creating private key, the algorithm to use    | `string`       | RSA     |
| key_bits       | When creating private key, the length (in bits)    | `number`       | 2048    |

#### Notes

- Self-Signed Certificates are issued by Honest Achmed, and "valid" for 1 week
- Self-Signed Certificate hostname will be "localhost.localdomain" if `domains` is not provided

### Inputs relevant to HTTP(S) Load Balancers only

| Name            | Description                                              | Type          | Default |
|-----------------|----------------------------------------------------------|---------------|---------|
| classic         | Use Classic global HTTP(S) LB (not Envoy-based)          | `bool`        | false   | 
| routing_rules   | Routes to route hosts/paths to different backends        | `map(object)` | null    | 
| http_port       | Listener port for HTTP.  To disable HTTP, set to `null`  | `number`      | 80      |
| https_port      | Listener port for HTTPS. To disable HTTPS, set to `null` | `number`      | 443     |
| ssl_policy_name | Name of a pre-existing SSL Policy to use                 | `string`      | n/a     |
| tls_profile     | Profile to base a new SSL Policy on                      | `string`      | MODERN  |
| min_tls_version | Minimum TLS version to allow in new SSL Policy           | `string`      | TLS_1_2 |

#### Notes

- Currently, `ssl_policy_name` is only supported on Classic LB
- If `ssl_policy_name` is null, a new SSL Policy will be created using `tls_profile` and `min_tls_version` as parameters

### Inputs relevant to Network Load Balancers only

| Name          | Description                               | Type           | Default |
|---------------|-------------------------------------------|----------------|---------|
| ports         | Ports to enable on the frontend           | `list(number)` | null    | 
| all_ports     | Listener will accept traffic on all ports | `bool`         | false   |
| global_access | Allow access from all regions             | `bool`         | false   |

#### Notes

- `global_access` is only relevant to internal TCP/UDP Load Balancers

### Attributes for backends variable

| Name           | Description                                 | Type     | Default |
|----------------|---------------------------------------------|----------|---------|
| description    | Description for this Backend                | `string` | n/a     |
| timeout        | Timeout between LB and backend (in seconds) | `number` | 30      |
| port           | TCP Port of the Backend                     | `number` | 443     |
| port_name      | Name of the HTTP port        | `string` | http    |
| cloudarmor_policy | Name of the CloudArmor policy to apply | `string` | n/a |
| protocol       | Protocol of the Backend                     | `string` | TCP     |
| bucket_name    | Name of the GCS bucket                      | `string` | n/a     |
| fqdn           | FQDN Hostname (Internet NEGs only)          | `string` | n/a     |
| ip_address     | IP Address (Internet NEGs Only)             | `string` | n/a     |

#### Notes

- Timeout behavior depends on LB type.  See notes above.
- Backend buckets can also be used with `type = "bucket"`.  If `bucket_name` is not provided, bucket name is assumed to be the key 
- `port_name` and `cloudamor_policy` are only supported on HTTP(S) LBs
- `fqdn` and `ip_address` are only supported on Classic HTTP(S) LB currently

#### backend attributes for HTTP(S) LBs

| Name               | Description                          | Type      | Default |
|--------------------|--------------------------------------|-----------|---------|
| enable_cdn         | Enable Google CDN for this backend   | `bool`    | false   |
| cdn_cache_mode     | Caching mode to use                  | `string`  | STATIC  |
| cloudarmor_policy  | Key of the CloudAmor Policy to use   | `string`  | null    |
| logging            | Whether to log requests              | `bool`    | false   |
| logging_rate       | Ratio of requests to log (1 = 100%)  | `number`  | 1       |

#### backend attributes for TCP & UDP LBs

| Name            | Description                                   | Type     | Default |
|-----------------|-----------------------------------------------|----------|---------|
| max_connections | Max number of connections to send the backend | `number` | 32768   |

## Outputs

| Name         | Description                          | Type     |
|--------------|--------------------------------------|----------|
| name         | Name of the load balancer            | `string` |
| address      | IPv4 address of the load balancer    | `string` |
| ipv6_address | IPv6 address of the load balancer    | `string` |
| is_global    | Whether or not LB is Global          | `bool`   |
| is_regional  | Whether or not LB is Global          | `bool`   |
| is_https     | Whether or not LB is HTTP(S)         | `bool`   |
| is_classic   | Whether or not LB is HTTP(S) Classic | `bool`   |
| is_internal  | Whether or not LB is Internal        | `bool`   |
| type         | General Type of LB (TCP, HTTPS, etc) | `string` |
| lb_scheme    | Load Balancer Scheme used            | `string` |

### Usage Examples

#### Internal TCP/UDP Load balancer with existing unmanaged instance groups

```
region        = "us-west1"
healthchecks = {
  smtp = {
    port     = 25
    regional = true
  }
}
backends = {
  mail-relay = {
    ig_ids           = [
      "projects/myproject/zones/us-west1-a/instanceGroups/mail-relay",
      "projects/myproject/zones/us-west1-b/instanceGroups/mail-relay",
      "projects/myproject/zones/us-west1-c/instanceGroups/main-relay"
    ]
    healthcheck      = "smtp"
    affinity_type    = "CLIENT_IP_PORT_PROTO"
  }
}
ports         = [25, 465, 587]
global_access = true
```

#### Global Load Balancer Mix of Cloud Run and Buckets with 3rd party SSL Cert

```
backends = {
  cloud-run = {
    docker_image   = "johnnylingo/flask2-sqlalchemy2"
    container_port = 8081
  }
  static-bucket = {
    bucket_name = "my-static-bucket"
    enable_cdn  = true
  }
}
routing_rules = {
  api = {
    hosts = ["api.mydomain.com"]
    backend = "cloud-run"
  }
  static-bucket = {
    hosts   = ["static.mydomain.com", "*-static.mydomain.com"]
  }
}
default_backend = "static-bucket"
ssl_certs = {
  example = {
    certificate = "example.crt"
    private_key = "example.rsa"
    description = "My precious cert and key"
  }
}
```

#### Global HTTP(S) Load Balancer with multiple Cloud Run backends

```
backends = {
  rnegs = [
    cloud_run_us = {
      container_name  = "nginx1-us"
      container_image = "marketplace.gcr.io/google/nginx1"
      region          = "us-central1"
    }
    cloud_run_eu = {
      container_name  = "nginx1-eu"
      container_image = "marketplace.gcr.io/google/nginx1"
      region          = "europe-west4"
    }
  ]
}
default_backend = "cloud_run_us"
```

#### Classic HTTP(S) Load Balancer with Internet NEGs

```
classic = true
backends = {
  api = {
    ineg = {  
      fqdn     = "api.olddomain.com"
    }
    protocol = "https"
    timeout  = 60
  }
  cdn = {
    ineg = {
      ip_address = "203.0.113.123"
    }
    protocol   = "http"
    port       = 8080
  }
}
routing_rules = {
  api = {
    hosts   = ["api.newdomain.com"]
  }
  cdn = {
    hosts   = ["cdn.newdomain.com"]
  }
}
```

#### Regional External HTTP(S) Load Balancer with PSC Backend

```
backends = {
  psc-service-name = {
    rnegs = [
      {
        psc_target   = "projects/project-xyz/regions/us-central1/serviceAttachments/psc-service-name"
        region       = "us-central1"
        network_name = "custom-network"
        subnet_name  = "us-central1"
      }
    ]
  }
}
```

#### Publish Load Balancer via Private Service Connect

```
psc = {
  service_name       = "my-service"
  nat_subnet_names   = ["psc-subnet-1"]
  accept_project_ids = ["consumer-project-1", "consumer-project-2"]
  connection_limit   = 1024 
}
```
