> [!INFO]
> The n8n Helm chart is growing, and needs your help!
> We're looking for additional passionate maintainers and contributors
> to improve and maintain this chart, governance, development, documentation and CI/CD workflows.
> If you're interested in making a difference,
> [join the discussion](https://github.com/8gears/n8n-helm-chart/discussions/90).

> [!WARNING]
> Version 1.0.0 of this Chart includes breaking changes and is not backwards compatible with previous versions.
> Please review the migration guide below before upgrading.
> 
# n8n Helm Chart for Kubernetes

[n8n](https://github.com/n8n-io/n8n) is an extendable workflow automation tool.
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/n8n)](https://artifacthub.io/packages/helm/open-8gears/n8n)
The Helm chart source code location is [github.com/8gears/n8n-helm-chart](https://github.com/8gears/n8n-helm-chart)

## Requirements

Before you start, make sure you have the following tools ready:

- Helm >= 3.8
- external Postgres DB or embedded SQLite (SQLite is bundled with n8n)
- Helmfile (Optional)

## Overview

The `values.yaml` file is divided into a multiple n8n and Kubernetes specific sections.

1. Global and chart wide values, like the image repository, image tag, etc.
2. Ingress, (default is nginx, but you can change it to your own ingress controller)
3. Main n8n app configuration + Kubernetes specific settings
4. Worker related settings + Kubernetes specific settings
5. Webhook related settings + Kubernetes specific settings
6. Raw Resources to pass through your own manifests like GatewayAPI, ServiceMonitor etc.
7. Redis related settings + Kubernetes specific settings

## Setting Configuration Values and Environment Variables

These n8n specific settings should be added to `main.config:` or `main.secret:` in the `values.yaml` file.

See the [example](#examples) section and other example in the `/examples` directory of this repo.

> [!IMPORTANT]
> The YAML nodes `config` and `secret` in the values.yaml are transformed 1:1 into ENV variables.

```yaml
main:
  config:
      n8n:
        encryption_key: "my_secret" # ==> turns into ENV: N8N_ENCRYPTION_KEY=my_secret
      db:
        type: postgresdb # ==> turns into ENV: DB_TYPE=postgresdb
        postgresdb: 
          host: 192.168.0.52 # ==> turns into ENV: DB_POSTGRESDB_HOST=192.168.0.52
      node:
        function_allow_builtin: "*" # ==> turns into ENV: NODE_FUNCTION_ALLOW_BUILTIN="*"
```

Consult the [n8n Environment Variables Documentation]( https://docs.n8n.io/hosting/configuration/environment-variables/)

You decide what should go into `secret` and what should be a `config`.
There is no restriction, mix and match as you like.

# Installation

Install chart

```shell
helm install my-n8n oci://8gears.container-registry.com/library/n8n --version 1.0.0
```

# Examples

A typical example of a config in combination with a secret.
You can find various other examples in the `examples` directory of this repository.

```yaml
#small deployment with nodeport for local testing or small deployments
main:
  config:
    n8n:
      hide_usage_page: true
  secret:
    n8n:
      encryption_key: "<your-secure-encryption-key>"
  resources:
    limits:
      memory: 2048Mi
    requests:
      memory: 512Mi
  service:
    type: NodePort
    port: 5678
```

# Values File

## N8N Specific Config Section

Every possible n8n config value can be set,
even if it is not mentioned in the excerpt below.
Treat the n8n provided configuration documentation as the source of truth,
this Charts just forwards everything down to the n8n pods.

```yaml
#
# General Config
#

# default .Chart.Name
nameOverride:

# default .Chart.Name or .Values.nameOverride
fullnameOverride:


#
# Common Kubernetes Config Settings for this entire n8n deployment
#
image:
  repository: n8nio/n8n
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
imagePullSecrets: []

#
# Ingress
#
ingress:
  enabled: false
  annotations: {}
  # define a custom ingress class Name, like "traefik" or "nginx"
  className: ""
  hosts:
    - host: workflow.example.com
      paths: []
  tls:
    - hosts:
        - workflow.example.com
      secretName: host-domain-cert

# the main (n8n) application related configuration + Kubernetes specific settings
# The config: {} dictionary is converted to environmental variables in the ConfigMap.
main:
  # See https://docs.n8n.io/hosting/configuration/environment-variables/ for all values.
  config:
  #    n8n:
  #    db:
  #      type: postgresdb
  #      postgresdb:
  #        host: 192.168.0.52

  # Dictionary for secrets, unlike config:, the values here will end up in the secret file.
  # The YAML entry db.postgresdb.password: my_secret is transformed DB_POSTGRESDB_password=bXlfc2VjcmV0
  # See https://docs.n8n.io/hosting/configuration/environment-variables/
  secret:
  #    n8n:
  #     if you run n8n stateless, you should provide an encryption key here.
  #      encryption_key:
  #
  #    database:
  #      postgresdb:
  #        password: 'big secret'

  # Extra environmental variables, so you can reference other configmaps and secrets into n8n as env vars.
  extraEnv:
  #    N8N_DB_POSTGRESDB_NAME:
  #      valueFrom:
  #        secretKeyRef:
  #          name: db-app
  #          key: dbname
  #
  # N8n Kubernetes specific settings
  #
  persistence:
    # If true, use a Persistent Volume Claim, If false, use emptyDir
    enabled: false
    # what type volume, possible options are [existing, emptyDir, dynamic] dynamic for Dynamic Volume Provisioning, existing for using an existing Claim
    type: emptyDir
    # Persistent Volume Storage Class
    # If defined, storageClassName: <storageClass>
    # If set to "-", storageClassName: "", which disables dynamic provisioning
    # If undefined (the default) or set to null, no storageClassName spec is
    #   set, choosing the default provisioner.  (gp2 on AWS, standard on
    #   GKE, AWS & OpenStack)
    #
    # storageClass: "-"
    # PVC annotations
    #
    # If you need this annotation include it under `values.yml` file and pvc.yml template will add it.
    # This is not maintained at Helm v3 anymore.
    # https://github.com/8gears/n8n-helm-chart/issues/8
    #
    # annotations:
    #   helm.sh/resource-policy: keep
    # Persistent Volume Access Mode
    #
    accessModes:
      - ReadWriteOnce
    # Persistent Volume size
    size: 1Gi
    # Use an existing PVC
    # existingClaim:

  extraVolumes: []
  #    - name: db-ca-cert
  #      secret:
  #        secretName: db-ca
  #        items:
  #          - key: ca.crt
  #            path: ca.crt

  extraVolumeMounts: []
  #    - name: db-ca-cert
  #      mountPath: /etc/ssl/certs/postgresql
  #      readOnly: true


  # Number of desired pods.
  replicaCount: 1

  # here you can specify the deployment strategy as Recreate or RollingUpdate with optional maxSurge and maxUnavailable
  # If these options are not set, default values are 25%
  # deploymentStrategy:
  #  type: Recreate | RollingUpdate
  #  maxSurge: "50%"
  #  maxUnavailable: "50%"

  deploymentStrategy:
    type: "Recreate"
    #  maxSurge: "50%"
    #  maxUnavailable: "50%"

  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # Annotations to add to the service account
    annotations: {}
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: ""

  podAnnotations: {}
  podLabels: {}

  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  #  runAsNonRoot: true
  #  runAsUser: 1000

  # here you can specify lifecycle hooks - it can be used e.g., to easily add packages to the container without building
  # your own docker image
  # see https://github.com/8gears/n8n-helm-chart/pull/30
  lifecycle: {}

  #  here's the sample configuration to add mysql-client to the container
  # lifecycle:
  #  postStart:
  #    exec:
  #      command: ["/bin/sh", "-c", "apk add mysql-client"]

  # here you can override a command for main container
  # it may be used to override a starting script (e.g., to resolve issues like https://github.com/n8n-io/n8n/issues/6412) or run additional preparation steps (e.g., installing additional software)
  command: []

  # sample configuration that overrides starting script and solves above issue (also it runs n8n as root, so be careful):
  # command:
  #  - tini
  #  - --
  #  - /bin/sh
  #  - -c
  #  - chmod o+rx /root; chown -R node /root/.n8n || true; chown -R node /root/.n8n; ln -s /root/.n8n /home/node; chown -R node /home/node || true; node /usr/local/bin/n8n

  # here you can override the livenessProbe for the main container
  # it may be used to increase the timeout for the livenessProbe (e.g., to resolve issues like

  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # here you can override the readinessProbe for the main container
  # it may be used to increase the timeout for the readinessProbe (e.g., to resolve issues like

  readinessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started.
  # See https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  initContainers: []
  #    - name: init-data-dir
  #      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  #      command: [ "/bin/sh", "-c", "mkdir -p /home/node/.n8n/" ]
  #      volumeMounts:
  #        - name: data
  #          mountPath: /home/node/.n8n


  service:
    annotations: {}
    # -- Service types allow you to specify what kind of Service you want.
    # E.g., ClusterIP, NodePort, LoadBalancer, ExternalName
    type: ClusterIP
    # -- Service port
    port: 80

  resources: {}
  # We usually recommend not specifying default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
    # targetMemoryUtilizationPercentage: 80

  nodeSelector: {}
  tolerations: []
  affinity: {}

# # # # # # # # # # # # # # # #
#
# Worker related settings
#
worker:
  enabled: false
  count: 2
  # You can define the number of jobs a worker can run in parallel by using the concurrency flag. It defaults to 10. To change it:
  concurrency: 10

  #
  # Worker Kubernetes specific settings
  #
  persistence:
    # If true, use a Persistent Volume Claim, If false, use emptyDir
    enabled: false
    # what type volume, possible options are [existing, emptyDir, dynamic] dynamic for Dynamic Volume Provisioning, existing for using an existing Claim
    type: emptyDir
    # Persistent Volume Storage Class
    # If defined, storageClassName: <storageClass>
    # If set to "-", storageClassName: "", which disables dynamic provisioning
    # If undefined (the default) or set to null, no storageClassName spec is
    #   set, choosing the default provisioner.  (gp2 on AWS, standard on
    #   GKE, AWS & OpenStack)
    #
    # storageClass: "-"
    # PVC annotations
    #
    # If you need this annotation include it under `values.yml` file and pvc.yml template will add it.
    # This is not maintained at Helm v3 anymore.
    # https://github.com/8gears/n8n-helm-chart/issues/8
    #
    # annotations:
    #   helm.sh/resource-policy: keep
    # Persistent Volume Access Mode
    accessModes:
      - ReadWriteOnce
    # Persistent Volume size
    size: 1Gi
    # Use an existing PVC
    # existingClaim:
  # Number of desired pods.
  replicaCount: 1

  # here you can specify the deployment strategy as Recreate or RollingUpdate with optional maxSurge and maxUnavailable
  # If these options are not set, default values are 25%
  # deploymentStrategy:
  #  type: RollingUpdate
  #  maxSurge: "50%"
  #  maxUnavailable: "50%"

  deploymentStrategy:
    type: "Recreate"
    # maxSurge: "50%"
    # maxUnavailable: "50%"

  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # Annotations to add to the service account
    annotations: {}
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: ""

  podAnnotations: {}

  podLabels: {}

  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  #  runAsNonRoot: true
  #  runAsUser: 1000

  # here you can specify lifecycle hooks - it can be used e.g., to easily add packages to the container without building
  # your own docker image
  # see https://github.com/8gears/n8n-helm-chart/pull/30
  lifecycle: {}

  #  here's the sample configuration to add mysql-client to the container
  # lifecycle:
  #  postStart:
  #    exec:
  #      command: ["/bin/sh", "-c", "apk add mysql-client"]

  # here you can override a command for worker container
  # it may be used to override a starting script (e.g., to resolve issues like https://github.com/n8n-io/n8n/issues/6412) or
  # run additional preparation steps (e.g., installing additional software)
  command: []

  # sample configuration that overrides starting script and solves above issue (also it runs n8n as root, so be careful):
  # command:
  #  - tini
  #  - --
  #  - /bin/sh
  #  - -c
  #  - chmod o+rx /root; chown -R node /root/.n8n || true; chown -R node /root/.n8n; ln -s /root/.n8n /home/node; chown -R node /home/node || true; node /usr/local/bin/n8n

  # command args
  commandArgs: []

  # here you can override the livenessProbe for the main container
  # it may be used to increase the timeout for the livenessProbe (e.g., to resolve issues like
  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # here you can override the readinessProbe for the main container
  # it may be used to increase the timeout for the readinessProbe (e.g., to resolve issues like

  readinessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started.
  # See https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  initContainers: []

  service:
    annotations: {}
    # -- Service types allow you to specify what kind of Service you want.
    # E.g., ClusterIP, NodePort, LoadBalancer, ExternalName
    type: ClusterIP
    # -- Service port
    port: 80

  resources: {}
  # We usually recommend not specifying default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
    # targetMemoryUtilizationPercentage: 80

  nodeSelector: {}
  tolerations: []
  affinity: {}

# Webhook related settings
# With .Values.scaling.webhook.enabled=true you disable Webhooks from the main process, but you enable the processing on a different Webhook instance.
# See https://github.com/8gears/n8n-helm-chart/issues/39#issuecomment-1579991754 for the full explanation.
# Webhook processes rely on Redis too.
webhook:
  enabled: false  
  # additional (to main) config for webhook
  config: {}
  # additional (to main) config for webhook
  secret: {}

  # Extra environmental variables, so you can reference other configmaps and secrets into n8n as env vars.
  extraEnv: {}
  #   WEBHOOK_URL:
  #   value: "http://webhook.domain.tld"
     

  #
  # Webhook Kubernetes specific settings
  #
  persistence:
    # If true, use a Persistent Volume Claim, If false, use emptyDir
    enabled: false
    # what type volume, possible options are [existing, emptyDir, dynamic] dynamic for Dynamic Volume Provisioning, existing for using an existing Claim
    type: emptyDir
    # Persistent Volume Storage Class
    # If defined, storageClassName: <storageClass>
    # If set to "-", storageClassName: "", which disables dynamic provisioning
    # If undefined (the default) or set to null, no storageClassName spec is
    #   set, choosing the default provisioner.  (gp2 on AWS, standard on
    #   GKE, AWS & OpenStack)
    #
    # storageClass: "-"
    # PVC annotations
    #
    # If you need this annotation include it under `values.yml` file and pvc.yml template will add it.
    # This is not maintained at Helm v3 anymore.
    # https://github.com/8gears/n8n-helm-chart/issues/8
    #
    # annotations:
    #   helm.sh/resource-policy: keep
    # Persistent Volume Access Mode
    #
    accessModes:
      - ReadWriteOnce
    # Persistent Volume size
    #
    size: 1Gi
    # Use an existing PVC
    #
    # existingClaim:

  # Number of desired pods.
  replicaCount: 1

  # here you can specify the deployment strategy as Recreate or RollingUpdate with optional maxSurge and maxUnavailable
  # If these options are not set, default values are 25%
  # deploymentStrategy:
  #  type: RollingUpdate
  #  maxSurge: "50%"
  #  maxUnavailable: "50%"

  deploymentStrategy:
    type: "Recreate"

  nameOverride: ""
  fullnameOverride: ""

  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # Annotations to add to the service account
    annotations: {}
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: ""

  podAnnotations: {}

  podLabels: {}

  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  #  runAsNonRoot: true
  #  runAsUser: 1000

  # here you can specify lifecycle hooks - it can be used e.g., to easily add packages to the container without building
  # your own docker image
  # see https://github.com/8gears/n8n-helm-chart/pull/30
  lifecycle: {}

  #  here's the sample configuration to add mysql-client to the container
  # lifecycle:
  #  postStart:
  #    exec:
  #      command: ["/bin/sh", "-c", "apk add mysql-client"]

  # here you can override a command for main container
  # it may be used to override a starting script (e.g., to resolve issues like https://github.com/n8n-io/n8n/issues/6412) or
  # run additional preparation steps (e.g., installing additional software)
  command: []

  # sample configuration that overrides starting script and solves above issue (also it runs n8n as root, so be careful):
  # command:
  #  - tini
  #  - --
  #  - /bin/sh
  #  - -c
  #  - chmod o+rx /root; chown -R node /root/.n8n || true; chown -R node /root/.n8n; ln -s /root/.n8n /home/node; chown -R node /home/node || true; node /usr/local/bin/n8n
  # Command Arguments
  commandArgs: []

  # here you can override the livenessProbe for the main container
  # it may be used to increase the timeout for the livenessProbe (e.g., to resolve issues like

  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # here you can override the readinessProbe for the main container
  # it may be used to increase the timeout for the readinessProbe (e.g., to resolve issues like

  readinessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started.
  # See https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  initContainers: []

  service:
    annotations: {}
    # -- Service types allow you to specify what kind of Service you want.
    # E.g., ClusterIP, NodePort, LoadBalancer, ExternalName
    type: ClusterIP
    # -- Service port
    port: 80

  resources: {}
  # We usually recommend not specifying default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
    # targetMemoryUtilizationPercentage: 80
  nodeSelector: {}
  tolerations: []
  affinity: {}

#
# Additional resources
#

#  Takes a list of Kubernetes resources and merges each resource with a default metadata.labels map and
#  installs the result.
#  Use this to add any arbitrary Kubernetes manifests alongside this chart instead of kubectl and scripts.
resources: []
#  - apiVersion: v1
#    kind: ConfigMap
#    metadata:
#      name: example-config
#    data:
#      example.property.1: "value1"
#      example.property.2: "value2"
# As an alternative to the above, you can also use a string as the value of the data field.
#  - |
#    apiVersion: v1
#    kind: ConfigMap
#    metadata:
#      name: example-config-string
#    data:
#      example.property.1: "value1"
#      example.property.2: "value2"

# Add additional templates.
# In contrast to the resources field, these templates are not merged with the default metadata.labels map.
# The templates are rendered with the values.yaml file as the context.
templates: []
#  - |
#    apiVersion: v1
#    kind: ConfigMap
#    metadata:
#      name: my-config
#    stringData:
#      image_name: {{ .Values.image.repository }}

# Bitnami Valkey configuration
# https://artifacthub.io/packages/helm/bitnami/valkey
redis:
  enabled: false
  architecture: standalone

  primary:
    persistence:
      enabled: false
      existingClaim: ""
      size: 2Gi


```
## Migration Guide to Version 1.0.0

This version includes a complete redesign of the chart to better accommodate n8n configuration options.
Key changes include:
- Values restructured under `.Values.main`, `.Values.worker`, and `.Values.webhook`
- Updated deployment configurations
- New Redis integration requirements


## Scaling and Advanced Configuration Options

n8n provides a **queue-mode**, where the workload is shared between multiple
instances of the same n8n installation.
This provides a shared load over multiple instances and limited high
availability, because the controller instance remains as Single-Point-Of-Failure.

With the help of an internal/external redis server and by using the excellent
BullMQ, the tasks can be shared over different instances, which also can run on
different hosts.

[See docs about this Queue-Mode](https://docs.n8n.io/hosting/scaling/queue-mode/)

To enable this mode within this helm chart, you simply should
set `scaling.enable` to true.
This chart is configured to spawn two worker instances.

```yaml
scaling:
  enabled: true
```

You can define to spawn more workers, by set scaling.worker.count to a higher
number.
Also, it is possible to define your own external redis server.

```yaml
scaling:
  enabled: true
  redis:
    host: "redis-hostname"
    password: "redis-password-if-set"
```

If you want to use the internal redis server, set `redis.enable = true`. By
default, no redis server is spawned.

At last scaling option is it possible to create dedicated webhook instances,
which only process the webhooks.
If you set `scaling.webhook.enabled=true`, then webhook processing on the main
instance is disabled and by default a single webhook instance is started.

## Chart Release Workflow

1. Update the `Chart.yaml` with the new version numbers for the chart and/or app.
2. In `Chart.yaml`update/replace the content of the `artifacthub.io/changes` section. See Artifacthub [annotation referene](https://artifacthub.io/docs/topics/annotations/helm/) 
3. In GitHub create a new release with the the chart version number as the tag and a title.
