provider "helm" {
  kubernetes {
    host  = replace(yamldecode(rancher2_cluster_v2.this.kube_config).clusters[0].cluster.server, var.rancher_internal_fqdn, trimprefix(var.rancher_url, "https://"))
    token = yamldecode(rancher2_cluster_v2.this.kube_config).users[0].user.token
  }
}

provider "kubectl" {
  host  = replace(yamldecode(rancher2_cluster_v2.this.kube_config).clusters[0].cluster.server, var.rancher_internal_fqdn, trimprefix(var.rancher_url, "https://"))
  token            = yamldecode(rancher2_cluster_v2.this.kube_config).users[0].user.token
  load_config_file = false
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher_token
}
