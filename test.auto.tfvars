# Rancher options
rancher_url           = "https://rancher.lab-linux.com"
rancher_internal_fqdn = "rancher.mgt"
rancher_token         = "ABCD"

# Harvester options
harvester_cluster_name      = "harvester"
harvester_namespace         = "go-test"
harvester_network_namespace = "go-shared"
harvester_network_name      = "shared"
harvester_image_name        = "ubuntu18.04"
harvester_api               = "https://192.168.100.2:6443"

# Cluster options
cluster_name = "go-test"
node_pools = {
  masters = {
    count        = 1
    cpu_count    = 2
    memory_size  = 4
    os_disk_size = 40
    roles        = ["etcd", "controlplane", "worker"]
  }
}

# Let's encrypt/ACME
ingress_top_domain = "lab-linux.com"
ingress_subdomain  = "go"

acme_wildcard = true
acme_email           = "email@cie.com"
acme_prod            = false
cloudflare_api_token = "ABCD"

# Specific hosting env options
proxy_host                = "router.maas:3128"
root_ca_cert_path         = "files/private_ca.crt"
container_registry_mirror = "https://harbor.tools.mgt"
container_registries = {
  #rewrite library = hostname
  docker = "docker.io"
  quay   = "quay.io"
  suse   = "registry.suse.com"
  gitlab = "registry.gitlab.com"
}