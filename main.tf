locals {

  fqdn = "rook.${var.dns_zone}"
  template_vars = {
    ingress_tls             = var.dashboard_ssl
    host                    = local.fqdn
    cluster_issuer          = var.cluster_issuer
    ingress_class           = var.ingress_class
    ingress_enabled         = var.ingress_enabled
    custom_blockpools       = var.custom_blockpools
    custom_filesystems      = var.custom_filesystems
    custom_objectstores     = var.custom_objectstores
    fs_volumesnapshot_class = var.fs_volumesnapshot_class
    bp_volumesnapshot_class = var.bp_volumesnapshot_class
  }

  helm_chart_values = templatefile("${path.module}/manifests/values.yaml.tpl", local.template_vars)

}

resource "kubernetes_namespace" "rook_ceph" {
  metadata {
    name = var.operator_namespace
  }
  timeouts {
    delete = "10m"
  }
}

resource "helm_release" "rook_ceph_operator" {
  name       = var.chart_name
  chart      = var.chart_name
  version    = var.rook_version
  repository = var.helm_repository
  namespace  = kubernetes_namespace.rook_ceph.metadata[0].name
  timeout    = 600

  set {
    name  = "crds.enabled"
    value = var.enable_crds
  }

  set {
    name  = "rbacEnable"
    value = var.enable_rbac
  }

  set {
    name  = "pspEnable"
    value = var.enable_psp
  }

  set {
    name  = "log_level"
    value = var.log_level
  }

  set {
    name  = "csi.enableRbdDriver"
    value = var.enable_rbd_driver
  }

  set {
    name  = "csi.enableCephfsDriver"
    value = var.enable_cephfs_driver
  }

  set {
    name  = "csi.enablePluginSelinuxHostMount"
    value = var.enable_plugins_selinux
  }

  set {
    name  = "csi.provisionerReplicas"
    value = var.provisioner_replicas
  }

  set {
    name  = "csi.allowUnsupportedVersion"
    value = var.allow_unsupported_version
  }

  set {
    name  = "csi.csiAddons.enabled"
    value = var.enable_csi_addons
  }

  set {
    name  = "enableSelinuxRelabeling"
    value = var.enable_selinux_relabeling
  }

  set {
    name  = "hostpathRequiresPrivileged"
    value = var.hostpath_privileged
  }

  set {
    name  = "monitoring.enabled"
    value = var.enable_monitoring
  }

}

resource "helm_release" "rook_ceph_cluster" {
  name       = "${var.chart_name}-cluster"
  chart      = "${var.chart_name}-cluster"
  version    = var.rook_version
  repository = var.helm_repository
  namespace  = kubernetes_namespace.rook_ceph.metadata[0].name
  timeout    = 600
  values     = [local.helm_chart_values]
  set {
    name  = "operatorNamespace"
    value = kubernetes_namespace.rook_ceph.metadata[0].name
  }

  set {
    name  = "toolbox.enabled"
    value = var.enable_toolbox
  }

  set {
    name  = "monitoring.enabled"
    value = var.enable_monitoring
  }

  set {
    name  = "pspEnable"
    value = var.enable_psp
  }

  set {
    name  = "cephClusterSpec.cephVersion.image"
    value = var.ceph_version
  }

  set {
    name  = "cephClusterSpec.cephVersion.allowUnsupported"
    value = var.allow_unsupported_version
  }

  set {
    name  = "cephClusterSpec.dataDirHostPath"
    value = var.hostpath_dir
  }

  set {
    name  = "cephClusterSpec.mon.count"
    value = var.mon_count
  }

  set {
    name  = "cephClusterSpec.mon.allowMultiplePerNode"
    value = var.mon_multiple_per_node
  }

  set {
    name  = "cephClusterSpec.mgr.count"
    value = var.mgr_count
  }

  set {
    name  = "cephClusterSpec.mgr.allowMultiplePerNode"
    value = var.mgr_multiple_per_node
  }

  set {
    name  = "cephClusterSpec.dashboard.enabled"
    value = var.enable_dashboard
  }

  set {
    name  = "cephClusterSpec.dashboard.ssl"
    value = var.dashboard_ssl
  }


  #TODO
  # set {
  #   name  = "cephClusterSpec.network.provider"
  #   value = var.networking
  # }

  depends_on = [helm_release.rook_ceph_operator]

}
