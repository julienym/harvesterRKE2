locals {
  harv_lb_annotations = <<-YAML
    cloudprovider.harvesterhci.io/ipam: pool
    loadbalancer.harvesterhci.io/namespace: ${var.harvester_namespace}
  YAML
}