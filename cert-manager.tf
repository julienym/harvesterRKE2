resource "helm_release" "cert-manager" {
  depends_on = [rancher2_cluster_sync.this]

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  create_namespace = true
  namespace        = "cert-manager"

  values = [
    <<-YAML
      installCRDs: true
      ${var.proxy_host != "" ? <<-EOT
        extraEnv:
        - name: http_proxy
          value: ${var.proxy_host}
        - name: https_proxy
          value: ${var.proxy_host}
        - name: no_proxy
          value: 127.0.0.1,localhost,10.43.0.0/16
      EOT
      : ""}
    YAML
  ]
}

resource "kubectl_manifest" "cloudflare_secret" {
  count      = var.acme_wildcard ? 1 : 0
  depends_on = [helm_release.cert-manager]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: cloudflare-api-token-secret
      namespace: cert-manager
    type: Opaque
    data:
      api-token: ${base64encode(var.cloudflare_api_token)}
  YAML
}

resource "kubectl_manifest" "issuer" {
  count      = var.acme_wildcard ? 1 : 0
  depends_on = [helm_release.cert-manager]

  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: letsencrypt
      namespace: cert-manager
    spec:
      acme:
        email: ${var.acme_email}
        server: https://acme-${var.acme_prod ? "" : "staging-"}v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: issuer-account-key
        solvers:
        - dns01:
            cloudflare:
              apiTokenSecretRef:
                name: ${kubectl_manifest.cloudflare_secret[0].name}
                key: api-token
          selector:
            dnsNames:
            - '${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}'
            - '*.${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}'
  YAML
}

resource "kubectl_manifest" "wildcard_cert" {
  count      = var.acme_wildcard ? 1 : 0
  depends_on = [kubectl_manifest.issuer]

  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: acme-wildcard
      namespace: cert-manager
    spec:
      secretName: wildcard-tls-secret
      issuerRef: 
        kind: Issuer
        name: letsencrypt
      commonName: '*.${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}'
      dnsNames:
        - '*.${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}'
  YAML
}
