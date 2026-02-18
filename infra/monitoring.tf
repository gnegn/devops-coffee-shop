resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [module.eks, module.lb_controller_role]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = "2.8.0"

  set {
    name  = "loki.persistence.enabled"
    value = "true"
  }

  set {
    name  = "loki.persistence.size"
    value = "10Gi"
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "helm_release" "prometheus" {
  name       = "monitor"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = "61.3.1"

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  set {
    name  = "grafana.adminPassword"
    value = "admin123"
  }

  set {
      name  = "grafana.grafana\\.ini.server.root_url"
      value = "/grafana/" 
  }

  set {
    name  = "grafana.grafana\\.ini.server.serve_from_sub_path"
    value = "true"
  }

  set {
    name  = "grafana.grafana\\.ini.server.domain"
    value = ""
    # Keeping the value empty allows Grafana to be accessed via the load balancer's DNS name without requiring a specific domain, which simplifies access in our setup.
  }

  set {
    name  = "grafana.grafana\\.ini.security.allow_embedding"
    value = "true"
  }

  set {
    name  = "grafana.additionalDataSources[0].name"
    value = "Loki"
  }
  set {
    name  = "grafana.additionalDataSources[0].type"
    value = "loki"
  }
  set {
    name  = "grafana.additionalDataSources[0].url"
    value = "http://loki:3100"
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}