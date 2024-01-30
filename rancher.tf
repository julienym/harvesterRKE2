data "rancher2_cluster_v2" "harvester" {
  name            = var.harvester_cluster_name
  fleet_namespace = "fleet-default"
}

resource "rancher2_cloud_credential" "harvester" {
  name = "${data.rancher2_cluster_v2.harvester.name}-${split(":", var.rancher_token)[0]}"
  harvester_credential_config {
    cluster_id         = data.rancher2_cluster_v2.harvester.cluster_v1_id
    cluster_type       = "imported"
    kubeconfig_content = data.rancher2_cluster_v2.harvester.kube_config
  }

  lifecycle {
    ignore_changes = [harvester_credential_config]
  }

  # Old method, see next resource
  # provisioner "local-exec" {
  #   command = <<-EOT
  #     curl -k -X POST ${var.rancher_url}/k8s/clusters/${data.rancher2_cluster_v2.harvester.cluster_v1_id}/v1/harvester/kubeconfig \
  #       -H 'Content-Type: application/json' \
  #       -u ${var.rancher_token} \
  #       -d '{"clusterRoleName": "harvesterhci.io:cloudprovider", "namespace": "${var.harvester_namespace}", "serviceAccountName": "'${var.cluster_name}'"}' | xargs | sed 's/\\n/\n/g' > ${var.cluster_name}-kubeconfig
  #     sleep 45s
  #   EOT
  # }
}

data "http" "harvester-kubeconfig" {
  depends_on = [rancher2_cloud_credential.harvester]

  url    = "${var.rancher_url}/k8s/clusters/${data.rancher2_cluster_v2.harvester.cluster_v1_id}/v1/harvester/kubeconfig"
  method = "POST"

  request_headers = {
    Accept        = "application/json"
    Authorization = "Basic ${base64encode(var.rancher_token)}"
  }

  request_body = jsonencode({
    clusterRoleName    = "harvesterhci.io:cloudprovider"
    namespace          = var.harvester_namespace
    serviceAccountName = var.cluster_name
  })

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

resource "rancher2_machine_config_v2" "this" {
  for_each = var.node_pools

  generate_name = "${var.cluster_name}-harvester-${each.key}"

  harvester_config {
    vm_namespace = var.harvester_namespace
    cpu_count    = each.value.cpu_count
    memory_size  = each.value.memory_size
    disk_info    = <<-EOF
      {
          "disks": [{
              "imageName": "${var.harvester_image_namespace}/${var.harvester_image_name}",
              "size": ${each.value.os_disk_size},
              "bootOrder": 1
          }]
      }
    EOF
    network_info = <<-EOF
      {
          "interfaces": [{
              "networkName": "${var.harvester_network_namespace}/${var.harvester_network_name}"
          }]
      }
    EOF
    ssh_user     = var.prov_user
    user_data = base64encode(templatefile(var.vm_user_data_tmpl_file, {
      prov_user             = var.prov_user
      prov_user_ssh_pub_key = file(pathexpand(var.prov_user_ssh_pub_key))
      root_ca_cert          = try(indent(3, file(var.root_ca_cert_path)), "")
      proxy_host            = var.proxy_host
    }))
    network_data = var.vm_network_data != null ? base64encode(var.vm_network_data) : null
  }
}

resource "rancher2_cluster_v2" "this" {
  name = var.cluster_name

  kubernetes_version           = var.kubernetes_version
  cloud_credential_secret_name = rancher2_cloud_credential.harvester.id

  rke_config {

    dynamic "machine_pools" {
      for_each = var.node_pools

      content {
        name               = machine_pools.key
        control_plane_role = contains(machine_pools.value.roles, "controlplane")
        etcd_role          = contains(machine_pools.value.roles, "etcd")
        worker_role        = contains(machine_pools.value.roles, "worker")
        quantity           = machine_pools.value.count
        machine_config {
          kind = rancher2_machine_config_v2.this[machine_pools.key].kind
          name = rancher2_machine_config_v2.this[machine_pools.key].name
        }
      }
    }

    # NGINX: https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
    chart_values = <<-EOT
      harvester-cloud-provider:
        cloudConfigPath: /var/lib/rancher/rke2/etc/config-files/cloud-provider-config
        global:
          cattle:
            clusterName: ${var.cluster_name}
      rke2-canal: {}
      harvester-csi-driver:
        replicasCount: 1
      rke2-ingress-nginx:
        controller:
          ingressClassResource:
            default: true
          extraArgs:
            ${var.acme_wildcard ? "default-ssl-certificate: cert-manager/wildcard-tls-secret" : ""}
          service:
            enabled: true
            type: LoadBalancer
            annotations:
              ${indent(8, local.harv_lb_annotations)}
    EOT

    machine_selector_config {
      config = <<-YAML
        cloud-provider-config: ${yamlencode(replace(trimsuffix(trimprefix(data.http.harvester-kubeconfig.response_body, "\""), "\""), "\\n", "\n"))}
        cloud-provider-name: harvester
        protect-kernel-defaults: false
      YAML
    }

    machine_global_config = <<-EOF
      cni: "canal"
      disable-kube-proxy: false
      etcd-expose-metrics: false
    EOF

    registries {
      dynamic "mirrors" {
        for_each = var.container_registry_mirror != "" ? var.container_registries : {}

        content {
          hostname  = mirrors.value
          endpoints = [var.container_registry_mirror]
          rewrites = {
            "(.*)" = "${mirrors.key}/$1"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [rke_config[0].machine_selector_config[0].config]
  }
}

resource "rancher2_cluster_sync" "this" {
  cluster_id = rancher2_cluster_v2.this.cluster_v1_id

  state_confirm = 6
}
