# harvesterRKE2
Create an RKE2 cluster with Harvester

This will create an RKE2 downstream cluster under Rancher using Harvester as the cloud provider.

## Requirements

- Access to a Rancher server with at minimum a project_member role to a Harvester cluster project
- A user created API token to operate on Rancher



## Optional features

- Let's encrypt/ACME setup using DNS with Cloudflare
- Proxy with private CA
- Container registry mirrors



## Limitations/Know bugs

- When the cluster is created, RKE2 Nginx service will request a Harvester VIP Load Balancer, but the deletion of the Terraform/Cluster would not delete that LB, it need to be deleted manually in Harvester.



## How-to on lab-linux.com

1. Please submit the form sent to you with an official invite
2. Wait for the account and networking setup to be done
3. Update your own tfvars (rename or replace test.auto.tfvars)
4. Make sure your dynamic DNS is fresh
5. Deploy!

# Terraform-Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.12.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | = 3.4.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | = 1.14.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | = 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.12.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/2.12.0/docs/resources/release) | resource |
| [kubectl_manifest.cloudflare_secret](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.ingress_test_deploy](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.ingress_test_ingress](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.ingress_test_svc](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.issuer](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.wildcard_cert](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [rancher2_cloud_credential.harvester](https://registry.terraform.io/providers/rancher/rancher2/3.2.0/docs/resources/cloud_credential) | resource |
| [rancher2_cluster_sync.this](https://registry.terraform.io/providers/rancher/rancher2/3.2.0/docs/resources/cluster_sync) | resource |
| [rancher2_cluster_v2.this](https://registry.terraform.io/providers/rancher/rancher2/3.2.0/docs/resources/cluster_v2) | resource |
| [rancher2_machine_config_v2.this](https://registry.terraform.io/providers/rancher/rancher2/3.2.0/docs/resources/machine_config_v2) | resource |
| [http_http.harvester-kubeconfig](https://registry.terraform.io/providers/hashicorp/http/3.4.0/docs/data-sources/http) | data source |
| [rancher2_cluster_v2.harvester](https://registry.terraform.io/providers/rancher/rancher2/3.2.0/docs/data-sources/cluster_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_email"></a> [acme\_email](#input\_acme\_email) | ACME email | `string` | `""` | no |
| <a name="input_acme_prod"></a> [acme\_prod](#input\_acme\_prod) | Should a ACME production env cert be requested | `bool` | `false` | no |
| <a name="input_acme_wildcard"></a> [acme\_wildcard](#input\_acme\_wildcard) | Should we create an ACME Let's encrypt wildcard certificate | `bool` | `false` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Cert-Manager chart version | `string` | `"v1.13.2"` | no |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API Token for let's encrypt | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name to create | `string` | n/a | yes |
| <a name="input_container_registries"></a> [container\_registries](#input\_container\_registries) | Container registries that need to be pulled from mirror | `map(string)` | `{}` | no |
| <a name="input_container_registry_mirror"></a> [container\_registry\_mirror](#input\_container\_registry\_mirror) | Container registry mirror | `string` | `""` | no |
| <a name="input_harvester_api"></a> [harvester\_api](#input\_harvester\_api) | Harvester API endpoint URL | `string` | n/a | yes |
| <a name="input_harvester_cluster_name"></a> [harvester\_cluster\_name](#input\_harvester\_cluster\_name) | Harvester cluster name | `string` | n/a | yes |
| <a name="input_harvester_image_name"></a> [harvester\_image\_name](#input\_harvester\_image\_name) | Harvester cloud image name | `string` | `"ubuntu18.04"` | no |
| <a name="input_harvester_image_namespace"></a> [harvester\_image\_namespace](#input\_harvester\_image\_namespace) | Where the VM cloud image would be get from | `string` | `"harvester-public"` | no |
| <a name="input_harvester_namespace"></a> [harvester\_namespace](#input\_harvester\_namespace) | Harvester operating namespace | `string` | n/a | yes |
| <a name="input_harvester_network_name"></a> [harvester\_network\_name](#input\_harvester\_network\_name) | Harvester network name to use for VM | `string` | n/a | yes |
| <a name="input_harvester_network_namespace"></a> [harvester\_network\_namespace](#input\_harvester\_network\_namespace) | Harvester VM network namespace | `string` | n/a | yes |
| <a name="input_ingress_subdomain"></a> [ingress\_subdomain](#input\_ingress\_subdomain) | Ingress subdomain before the root domain | `string` | `""` | no |
| <a name="input_ingress_top_domain"></a> [ingress\_top\_domain](#input\_ingress\_top\_domain) | Ingress top level Domain Name | `string` | `""` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Cluster's Kubernetes version | `string` | `"v1.26.11+rke2r1"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Node pools attributes | `map` | `{}` | no |
| <a name="input_prov_user"></a> [prov\_user](#input\_prov\_user) | VM user to create for ssh Rancher operations | `string` | `"ubuntu"` | no |
| <a name="input_prov_user_ssh_pub_key"></a> [prov\_user\_ssh\_pub\_key](#input\_prov\_user\_ssh\_pub\_key) | VM user ssh public key file path to inject under prov\_user account | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_proxy_host"></a> [proxy\_host](#input\_proxy\_host) | Proxy host with port | `string` | `""` | no |
| <a name="input_rancher_internal_fqdn"></a> [rancher\_internal\_fqdn](#input\_rancher\_internal\_fqdn) | Rancher self-aware FQDN - for dual ingress | `string` | `""` | no |
| <a name="input_rancher_token"></a> [rancher\_token](#input\_rancher\_token) | Rancher Token | `string` | n/a | yes |
| <a name="input_rancher_url"></a> [rancher\_url](#input\_rancher\_url) | Rancher URL | `string` | n/a | yes |
| <a name="input_root_ca_cert_path"></a> [root\_ca\_cert\_path](#input\_root\_ca\_cert\_path) | Extra CA root certificate file path to add to the VM | `string` | `""` | no |
| <a name="input_vm_network_data"></a> [vm\_network\_data](#input\_vm\_network\_data) | Cloud init network-data | `string` | `null` | no |
| <a name="input_vm_user_data_tmpl_file"></a> [vm\_user\_data\_tmpl\_file](#input\_vm\_user\_data\_tmpl\_file) | Cloud init user-data template file | `string` | `"cloud-inits/ubuntu.tftpl"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->