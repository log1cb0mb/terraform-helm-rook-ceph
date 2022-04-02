%{~ if ingress_enabled == true ~}
ingress:
  dashboard:
    annotations:
      %{~ if cluster_issuer != "" ~}
      cert-manager.io/cluster-issuer: ${cluster_issuer}
      %{~ endif ~}
      kubernetes.io/ingress.class: ${ingress_class}
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/server-snippet: |
        proxy_ssl_verify off;
    host:
      name: ${host}
      path: /
    tls:
    - hosts:
        - ${host}
      secretName: ceph-dashboard
%{~ endif ~}

cephBlockPools:
  - name: ceph-blockpool
    # see https://github.com/rook/rook/blob/master/Documentation/ceph-pool-crd.md#spec for available configuration
    spec:
      failureDomain: host
      replicated:
        size: 3
    storageClass:
      enabled: true
      name: ceph-block
      isDefault: true
      reclaimPolicy: Delete
      allowVolumeExpansion: true
      mountOptions: []
      # see https://github.com/rook/rook/blob/master/Documentation/ceph-block.md#provision-storage for available configuration
      parameters:
        # (optional) mapOptions is a comma-separated list of map options.
        # For krbd options refer
        # https://docs.ceph.com/docs/master/man/8/rbd/#kernel-rbd-krbd-options
        # For nbd options refer
        # https://docs.ceph.com/docs/master/man/8/rbd-nbd/#options
        # mapOptions: lock_on_read,queue_depth=1024

        # (optional) unmapOptions is a comma-separated list of unmap options.
        # For krbd options refer
        # https://docs.ceph.com/docs/master/man/8/rbd/#kernel-rbd-krbd-options
        # For nbd options refer
        # https://docs.ceph.com/docs/master/man/8/rbd-nbd/#options
        # unmapOptions: force

        # RBD image format. Defaults to "2".
        imageFormat: "2"
        # RBD image features. Available for imageFormat: "2". CSI RBD currently supports only `layering` feature.
        imageFeatures: layering
        # The secrets contain Ceph admin credentials.
        csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
        csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
        csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
        csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
        # Specify the filesystem type of the volume. If not specified, csi-provisioner
        # will set default as `ext4`. Note that `xfs` is not recommended due to potential deadlock
        # in hyperconverged settings where the volume is mounted on the same node as the osds.
        csi.storage.k8s.io/fstype: ext4
%{ for pools in custom_blockpools ~}
  - name: ${pools.name}
    spec:
      failureDomain: ${pools.failure_domain}
      replicated:
        size: ${pools.replicated_pool_size}
      %{~ if pools.crush_root != "" ~}
      crushRoot: ${pools.crush_root}
      %{~ endif ~}
    storageClass:
      enabled: ${pools.sc_enabled}
      name: ${pools.sc_name}
      isDefault: ${pools.sc_isdefault}
      reclaimPolicy: ${pools.sc_reclaim_policy}
      allowVolumeExpansion: ${pools.sc_allow_volume_expansion}
      mountOptions: []
      parameters:
        imageFormat: "2"
        imageFeatures: layering
        csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
        csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
        csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
        csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
        csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
        csi.storage.k8s.io/fstype: ext4
%{ endfor ~}

cephFileSystems:
  - name: ceph-filesystem
    # see https://github.com/rook/rook/blob/master/Documentation/ceph-filesystem-crd.md#filesystem-settings for available configuration
    spec:
      metadataPool:
        replicated:
          size: 3
      dataPools:
        - failureDomain: host
          replicated:
            size: 3
          # Optional and highly recommended, 'data0' by default, see https://github.com/rook/rook/blob/master/Documentation/ceph-filesystem-crd.md#pools
          name: data0
      metadataServer:
        activeCount: 1
        activeStandby: true
        resources:
          limits:
            cpu: "2000m"
            memory: "4Gi"
          requests:
            cpu: "1000m"
            memory: "4Gi"
    storageClass:
      enabled: true
      isDefault: false
      name: ceph-filesystem
      # (Optional) specify a data pool to use, must be the name of one of the data pools above, 'data0' by default
      pool: data0
      reclaimPolicy: Delete
      allowVolumeExpansion: true
      mountOptions: []
      # see https://github.com/rook/rook/blob/master/Documentation/ceph-filesystem.md#provision-storage for available configuration
      parameters:
        # The secrets contain Ceph admin credentials.
        csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
        csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
        csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
        csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
        csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
        csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
        # Specify the filesystem type of the volume. If not specified, csi-provisioner
        # will set default as `ext4`. Note that `xfs` is not recommended due to potential deadlock
        # in hyperconverged settings where the volume is mounted on the same node as the osds.
        csi.storage.k8s.io/fstype: ext4
%{ for fs in custom_filesystems ~}
  - name: ${fs.name}
    spec:
      metadataPool:
        replicated:
          size: ${fs.metadata_replicated_pool_size}
      dataPools:
        - failureDomain: ${fs.failure_domain}
          replicated:
            size: ${fs.data_replicated_pool_size}
          name: data0
      metadataServer:
        activeCount: 1
        activeStandby: true
        resources:
          limits:
            cpu: "2000m"
            memory: "4Gi"
          requests:
            cpu: "1000m"
            memory: "4Gi"
    storageClass:
      enabled: ${fs.sc_enabled}
      isDefault: ${fs.sc_isdefault}
      name: ${fs.sc_name}
      pool: data0
      reclaimPolicy: ${fs.sc_reclaim_policy}
      allowVolumeExpansion: ${fs.sc_allow_volume_expansion}
      mountOptions: []
      parameters:
        csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
        csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
        csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
        csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
        csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
        csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
        csi.storage.k8s.io/fstype: ext4
%{ endfor ~}

cephObjectStores:
  - name: ceph-objectstore
    # see https://github.com/rook/rook/blob/master/Documentation/ceph-object-store-crd.md#object-store-settings for available configuration
    spec:
      metadataPool:
        failureDomain: host
        replicated:
          size: 3
      dataPool:
        failureDomain: host
        erasureCoded:
          dataChunks: 2
          codingChunks: 1
      preservePoolsOnDelete: true
      gateway:
        port: 80
        resources:
          limits:
            cpu: "2000m"
            memory: "2Gi"
          requests:
            cpu: "1000m"
            memory: "1Gi"
        # securePort: 443
        # sslCertificateRef:
        instances: 1
      healthCheck:
        bucket:
          interval: 60s
    storageClass:
      enabled: true
      name: ceph-bucket
      reclaimPolicy: Delete
      # see https://github.com/rook/rook/blob/master/Documentation/ceph-object-bucket-claim.md#storageclass for available configuration
      parameters:
        # note: objectStoreNamespace and objectStoreName are configured by the chart
        region: us-east-1
%{ for stores in custom_objectstores ~}
  - name: ${stores.name}
    spec:
      metadataPool:
        failureDomain: ${stores.failure_domain}
        replicated:
          size: ${stores.metadata_replicated_pool_size}
      dataPool:
        failureDomain: ${stores.failure_domain}
        erasureCoded:
          dataChunks: ${stores.data_erasure_data_chunks}
          codingChunks: ${stores.data_erasure_coding_chunks}
      preservePoolsOnDelete: ${stores.preserve_pool_ondelete}
      gateway:
        port: ${stores.object_gw_port}
        resources:
          limits:
            cpu: "2000m"
            memory: "2Gi"
          requests:
            cpu: "1000m"
            memory: "1Gi"
        %{~ if stores.object_gw_secure_port != "" ~}
        securePort: ${stores.object_gw_secure_port}
        sslCertificateRef: ${stores.object_gw_ssl_cert}
        %{~ endif ~}
        instances: ${stores.object_gw_instnces}
      healthCheck:
        bucket:
          interval: ${stores.healthcheck_bucket_interval}
    storageClass:
      enabled: ${stores.sc_enabled}
      name: ${stores.sc_name}
      reclaimPolicy: ${stores.sc_reclaim_policy}
      parameters:
        region: us-east-1
%{ endfor ~}

%{ for fs_class in fs_volumesnapshot_class ~}
cephFileSystemVolumeSnapshotClass:
  enabled: ${fs_class.enabled}
  name: ${fs_class.name}
  isDefault: ${fs_class.isdefault}
  deletionPolicy: ${fs_class.deletion_policy}
  #TODO
  annotations: {}
  labels: {}
  # see https://rook.io/docs/rook/latest/ceph-csi-snapshot.html#cephfs-snapshots for available configuration
  parameters: {}
%{ endfor ~}

%{ for bp_class in bp_volumesnapshot_class ~}
cephBlockPoolsVolumeSnapshotClass:
  enabled: ${bp_class.enabled}
  name: ${bp_class.name}
  isDefault: ${bp_class.isdefault}
  deletionPolicy: ${bp_class.deletion_policy}
  #TODO
  annotations: {}
  labels: {}
  # see https://rook.io/docs/rook/latest/ceph-csi-snapshot.html#rbd-snapshots for available configuration
  parameters: {}
%{ endfor ~}

