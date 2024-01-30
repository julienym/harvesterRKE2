resource "kubectl_manifest" "ingress_test_deploy" {
  count = var.acme_wildcard ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: httpbin
      namespace: default
    spec:
      selector:
        matchLabels:
          app: httpbin
      replicas: 1
      template:
        metadata:
          labels:
            app: httpbin
        spec:
          containers:
          - name: httpbin
            image: kennethreitz/httpbin:latest
            ports:
            - containerPort: 80
  YAML
}

resource "kubectl_manifest" "ingress_test_svc" {
  count = var.acme_wildcard ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: httpbin
      namespace: default
    spec:
      selector:
        app: httpbin
      ports:
        - protocol: TCP
          port: 80
  YAML
}

resource "kubectl_manifest" "ingress_test_ingress" {
  count = var.acme_wildcard ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: httpbin
      namespace: default
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      ingressClassName: nginx
      rules:
      - host: "httpbin.${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}"
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: httpbin
                port:
                  number: 80
      tls:
      - hosts:
          - "httpbin.${var.cluster_name}.${var.ingress_subdomain}.${var.ingress_top_domain}"
  YAML
}