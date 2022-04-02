variable "chart_name" {
  type        = string
  description = "Chart name i.e rook-ceph or rook-ceph-cluster"
  default     = "rook-ceph"
}

variable "operator_namespace" {
  type        = string
  description = "Namespace of the main rook operator"
  default     = "rook-ceph"
}

variable "helm_repository" {
  type        = string
  description = "Rook Helm releases repository URL"
  default     = "https://charts.rook.io/release"
}

variable "rook_version" {
  type        = string
  description = "Rook release version for operator and ceph-cluster"
}

variable "enable_crds" {
  type        = bool
  description = "Create Rook CRDs"
  default     = true
}

variable "enable_rbac" {
  type        = bool
  description = "Create RBAC resources"
  default     = true
}

variable "enable_psp" {
  type        = bool
  description = "Pod Security Policy resources"
  default     = true
}

variable "log_level" {
  type        = string
  description = "The logging level for the operator: ERROR | WARNING | INFO | DEBUG"
  default     = "INFO"
}

variable "enable_rbd_driver" {
  type        = bool
  description = "Enable Ceph CSI RBD Driver"
  default     = true
}

variable "enable_cephfs_driver" {
  type        = bool
  description = "Enable Ceph CSI CephFS Driver"
  default     = true
}

variable "enable_plugins_selinux" {
  type        = bool
  description = "Enable SElinux for CSI Plugins pods"
  default     = false
}

variable "provisioner_replicas" {
  description = "Replicas for csi provisioner deployment"
  type        = number
  default     = 2
}

variable "allow_unsupported_version" {
  type        = bool
  description = "Allow starting unsupported ceph-csi image"
  default     = false
}

variable "enable_csi_addons" {
  type        = bool
  description = "Enable the CSIAddons sidecar"
  default     = false
}

variable "enable_selinux_relabeling" {
  type        = bool
  description = "SElinux relabling for volume mounts"
  default     = true
}

variable "hostpath_privileged" {
  type        = bool
  description = "Writing to the hostPath required for Ceph mon and osd pods when using SElinux enabled hosts"
  default     = false
}

variable "enable_monitoring" {
  type        = bool
  description = "Ceph monitoring, requires Prometheus to be pre-installed"
  default     = false
}

variable "enable_toolbox" {
  type        = bool
  description = "Enable Ceph debugging pod deployment"
  default     = false
}

variable "ceph_version" {
  type        = string
  description = "Ceph image tag"
  default     = "quay.io/ceph/ceph:v16.2.7"
}

variable "hostpath_dir" {
  type        = string
  description = "Path on the host where configuration data will be persisted"
  default     = "/var/lib/rook"
}

variable "mon_count" {
  description = "Number of mons. Generally recommended to be 3.For highest availability, an odd number of mons should be specified"
  type        = number
  default     = 3
}

variable "mon_multiple_per_node" {
  type        = bool
  description = "Mons should only be allowed on the same node for test environments where data loss is acceptable"
  default     = false
}

variable "mgr_count" {
  description = "If HA of the mgr is needed, increase the count to 2 for Active/Standby. Rook will update the mgr services to match the active mgr"
  type        = number
  default     = 2
}

variable "mgr_multiple_per_node" {
  type        = bool
  description = "Multiple mgr pods to be allowed on same node"
  default     = false
}

variable "enable_dashboard" {
  type        = bool
  description = "Enable CEPH Dashboard"
  default     = true
}

variable "dashboard_ssl" {
  type        = bool
  description = "Serve Ceph dashboard using SSL"
  default     = true
}

variable "networking" {
  type        = string
  description = "Network provider configuration i.e Host Networking or multus"
  default     = ""
}

variable "device_filter" {
  type        = string
  description = "A regular expression for short kernel names of devices (e.g. sda) that allows selection of devices to be consumed by OSDs"
  default     = "sdb"
}

variable "ingress_enabled" {
  type        = bool
  description = "Create ingress resource for Ceph dashboard"
  default     = true
}
variable "ingress_class" {
  type        = string
  description = "Ingress class name for Ceph dashboard in case using specific ingress controller"
  default     = "nginx"
}

variable "cluster_issuer" {
  type        = string
  description = "Cluster issuer name for signing certificate for SSL Dashboard"
}

variable "dns_zone" {
  description = "DNS Zone for Ingress host FQDN"
  type        = string
  default     = "example.com"
}

variable "custom_blockpools" {
  # see https://github.com/rook/rook/blob/master/Documentation/ceph-pool-crd.md#spec for available configuration
  type = list(object({
    name                      = string
    failure_domain            = string
    replicated_pool_size      = number
    crush_root                = string
    sc_name                   = string
    sc_enabled                = bool
    sc_isdefault              = bool
    sc_reclaim_policy         = string
    sc_allow_volume_expansion = bool
    mount_options             = map(string)
    parameters                = map(string)
  }))
  description = "Custom Ceph Block Pools in addition to default pool"
  default     = []
}

variable "custom_filesystems" {
  # see https://github.com/rook/rook/blob/master/Documentation/ceph-filesystem-crd.md#filesystem-settings for available configuration
  type = list(object({
    name                          = string
    failure_domain                = string
    metadata_replicated_pool_size = number
    data_replicated_pool_size     = number
    sc_name                       = string
    sc_enabled                    = bool
    sc_isdefault                  = bool
    sc_reclaim_policy             = string
    sc_allow_volume_expansion     = bool
    mount_options                 = map(string)
    parameters                    = map(string)
  }))
  description = "Custom Ceph Filesystems in addition to default pool"
  default     = []
}

variable "custom_objectstores" {
  # see https://github.com/rook/rook/blob/master/Documentation/ceph-object-store-crd.md#object-store-settings for available configuration
  type = list(object({
    name                          = string
    failure_domain                = string
    metadata_replicated_pool_size = number
    data_erasure_data_chunks      = number
    data_erasure_coding_chunks    = number
    preserve_pool_ondelete        = bool
    object_gw_port                = string
    object_gw_secure_port         = string
    object_gw_ssl_cert            = string
    object_gw_instnces            = number
    healthcheck_bucket_interval   = string
    sc_enabled                    = bool
    sc_name                       = string
    sc_reclaim_policy             = string
    # see https://github.com/rook/rook/blob/master/Documentation/ceph-object-bucket-claim.md#storageclass for available configuration
    parameters = map(string)
  }))
  description = "Custom Ceph Object Stores in addition to default pool"
  default     = []
}

variable "bp_volumesnapshot_class" {
  # see https://rook.io/docs/rook/latest/ceph-csi-snapshot.html#rbd-snapshots for available configuration
  type = list(object({
    enabled         = bool
    name            = string
    isdefault       = bool
    deletion_policy = string
    annotations     = map(string)
    labels          = map(string)
    parameters      = map(string)
  }))
  description = "RBD Volume Snapshot Class"
  default     = []
}

variable "fs_volumesnapshot_class" {
  # see https://rook.io/docs/rook/latest/ceph-csi-snapshot.html#cephfs-snapshots for available configuration
  type = list(object({
    enabled         = bool
    name            = string
    isdefault       = bool
    deletion_policy = string
    annotations     = map(string)
    labels          = map(string)
    parameters      = map(string)
  }))
  description = "CephFS Volume Snapshot Class"
  default     = []
}
