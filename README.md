[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/n8n)](https://artifacthub.io/packages/helm/open-8gears/n8n)

> [!NOTE]
> The n8n Helm chart is growing in popularity.
> We're looking for additional conscientious and accurate maintainers and contributors
> to improve and maintain this chart, governance, development, documentation and CI/CD workflows.
> If you're interested in making a difference,
> [join the discussion](https://github.com/8gears/n8n-helm-chart/discussions/90).


# n8n Helm Chart for Kubernetes

[n8n](https://github.com/n8n-io/n8n) is an extendable workflow automation tool.



The Helm chart source code location is [github.com/8gears/n8n-helm-chart](https://github.com/8gears/n8n-helm-chart)

## Requirements

Before you start, make sure you have the following tools ready:

- Helm >= 3.8
- external Postgres DB or embedded SQLite (SQLite is bundled with n8n)
- Helmfile (Optional)

## Overview

The `values.yaml` file is divided into multiple sections (global, n8n, and Kubernetes).
Use this structure to orient yourself.

1. Global and chart wide values, like the image repository, image tag, etc.
2. Ingress, (default is nginx, but you can change it to your own ingress controller)
3. Main n8n app configuration + Kubernetes specific settings
4. Worker related settings + Kubernetes specific settings
5. Webhook related settings + Kubernetes specific settings
6. Sandbox, the isolated execution environment the instance-ai module needs
7. Raw Resources to pass through your own manifests like GatewayAPI, ServiceMonitor etc.
8. Valkey/Redis related settings + Kubernetes specific settings

## Configurating N8n via Values and Environment Variables

These n8n configuration should be added to `main.config:` or `main.secret:` in the `values.yaml` file.

See the [example](#examples) section and other example in the `/examples` directory of this repo.

> [!IMPORTANT]
> The YAML nodes `config` and `secret` in the values.yaml are transformed 1:1 into K8s ENV variables.

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

## Global Section

```yaml

image:
  repository: n8nio/n8n
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
imagePullSecrets: []

# The Name to use for the chart. Will be the prefix of all resources aka. The Chart.Name (default is 'n8n')
nameOverride:
# Override the full name of the deployment. When empty, the name will be "{release-name}-{chart-name}" or the value of nameOverride if specified
fullnameOverride:

# Add entries to a pod's /etc/hosts file, mapping custom IP addresses to hostnames.
hostAliases: []
  #- ip: 8.8.8.8
  #  hostnames:
#    - service-example.local
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
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - workflow.example.com
      secretName: host-domain-cert
# ... next n8n specific section 
```
## N8N Specific Config Section in Values File

Every possible n8n config value can be set,
even if it is not mentioned in the excerpt below.
Treat the n8n provided configuration documentation as the source of truth,
this Charts just forwards everything down to the n8n pods.

```yaml
# ... after global section
# the main (n8n) application related configuration + Kubernetes specific settings
# The config: {} dictionary is converted to environmental variables in the ConfigMap.
main:
  # See https://docs.n8n.io/hosting/configuration/environment-variables/ for all values.
  config: {}
  #    n8n:
  #    db:
  #      type: postgresdb
  #      postgresdb:
  #        host: 192.168.0.52

  # Dictionary for secrets, unlike config:, the values here will end up in the secret file.
  # The YAML entry db.postgresdb.password: my_secret is transformed DB_POSTGRESDB_password=bXlfc2VjcmV0
  # See https://docs.n8n.io/hosting/configuration/environment-variables/
  secret: {}
  #    n8n:
  #     if you run n8n stateless, you should provide an encryption key here.
  #      encryption_key:
  #
  #    db:
  #      postgresdb:
  #        password: 'big secret'

  # Extra environmental variables, so you can reference other configmaps and secrets into n8n as env vars.
  extraEnv:
  #    N8N_DB_POSTGRESDB_NAME:
  #      valueFrom:
  #        secretKeyRef:
  #          name: db-app
  #          key: dbname
  # ... next k8s specific values section
  ```
## Kubernetes Specific Values Section

this section of the `yaml` file contains the typical Kubernetes specific setting 
related to the application deployment and operation but not the application itself.

```yaml
  # ... after n8n specific section
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


  # Number of desired pods. More than one pod is supported in n8n enterprise.
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

  # Annotations to be implemented on the main service deployment
  deploymentAnnotations: {}
  # Labels to be implemented on the main service deployment
  deploymentLabels: {}
  # Annotations to be implemented on the main service pod
  podAnnotations: {}
  # Labels to be implemented on the main service pod
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

  # Startup probe for the main container.
  # n8n only starts listening once the database connection and migrations are done, which can
  # take minutes on a first install. Without a startup probe the liveness probe below kills the
  # container mid-boot; while it runs, liveness and readiness are held off.
  startupProbe:
    httpGet:
      path: /healthz
      port: http
    periodSeconds: 10
    # Allow up to 5 minutes (30 x periodSeconds) to come up.
    failureThreshold: 30

  # Liveness probe for the main container.
  # Stays on /healthz, which only reports that the n8n process is running. A database outage
  # should drain pods from the Service via the readiness probe, not restart every pod at once.
  # To also have Kubernetes restart a pod whose DB connection never recovers, point this at
  # /healthz/readiness with a failureThreshold high enough to ride out a short blip.
  # See https://github.com/8gears/n8n-helm-chart/issues/308
  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # Readiness probe for the main container.
  # /healthz/readiness reflects the database connection and migration state, so a pod answering
  # "Database is not ready!" is removed from the Service endpoints. /healthz returns 200 in that
  # situation and would keep traffic flowing to a pod that cannot serve a single request.
  readinessProbe:
    httpGet:
      path: /healthz/readiness
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

  # Pod termination grace period in seconds
  terminationGracePeriodSeconds: 30

# # # # # # # # # # # # # # # #
#
# Worker related settings
#
worker:
  enabled: false

  # additional (to main) config for worker
  config:
    queue:
      health:
        check:
          # QUEUE_HEALTH_CHECK_ACTIVE. A worker starts no HTTP server unless this is true,
          # so the liveness/readiness probes below have nothing to talk to without it.
          active: true
          # QUEUE_HEALTH_CHECK_PORT. Uncomment to move the worker health server; the container
          # port and the probes follow it. N8N_PORT does not apply to workers.
          # port: 5678

  # additional (to main) config for worker
  secret: {}

  # Extra environmental variables, so you can reference other configmaps and secrets into n8n as env vars.
  extraEnv: {}

  # Define the number of jobs a worker can run in parallel by using the concurrency flag. Default is 10
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

  # Annotations to be implemented on the worker deployment
  deploymentAnnotations: {}
  # Labels to be implemented on the worker deployment
  deploymentLabels: {}
  # Annotations to be implemented on the worker pod
  podAnnotations: {}
  # Labels to be implemented on the worker pod
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

  # Startup probe for the worker container.
  # Both worker endpoints only exist when QUEUE_HEALTH_CHECK_ACTIVE is true (worker.config.queue.health.check.active above);
  # without it the worker serves no HTTP at all and these probes fail.
  # n8n only starts listening once the database connection and migrations are done, which can
  # take minutes on a first install. Without a startup probe the liveness probe below kills the
  # container mid-boot; while it runs, liveness and readiness are held off.
  startupProbe:
    httpGet:
      path: /healthz
      port: http
    periodSeconds: 10
    # Allow up to 5 minutes (30 x periodSeconds) to come up.
    failureThreshold: 30

  # Liveness probe for the worker container.
  # Stays on /healthz, which only reports that the n8n process is running. A database outage
  # should drain pods from the Service via the readiness probe, not restart every pod at once.
  # To also have Kubernetes restart a pod whose DB connection never recovers, point this at
  # /healthz/readiness with a failureThreshold high enough to ride out a short blip.
  # See https://github.com/8gears/n8n-helm-chart/issues/308
  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # Readiness probe for the worker container.
  # /healthz/readiness reflects the database and Redis connection state, so a worker that lost
  # either is removed from the Service endpoints. /healthz returns 200 in that situation.
  readinessProbe:
    httpGet:
      path: /healthz/readiness
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

  # Pod termination grace period in seconds
  terminationGracePeriodSeconds: 30

# Webhook related settings
# With .Values.scaling.webhook.enabled=true you disable Webhooks from the main process, but you enable the processing on a different Webhook instance.
# See https://github.com/8gears/n8n-helm-chart/issues/39#issuecomment-1579991754 for the full explanation.
# Webhook processes rely on Valkey/Redis too.
webhook:
  enabled: false
  # additional (to main) config for webhook
  config: {}
  # additional (to main) config for webhook
  secret: {}

  # Extra environmental variables, so you can reference other configmaps and secrets into n8n as env vars.
  extraEnv: {}
  #   WEBHOOK_URL:
  #     value: "http://webhook.domain.tld"


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

  # Annotations to be implemented on the webhook deployment
  deploymentAnnotations: {}
  # Labels to be implemented on the webhook deployment
  deploymentLabels: {}
  # Annotations to be implemented on the webhook pod
  podAnnotations: {}
  # Labels to be implemented on the webhook pod
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

  # Startup probe for the webhook container.
  # n8n only starts listening once the database connection and migrations are done, which can
  # take minutes on a first install. Without a startup probe the liveness probe below kills the
  # container mid-boot; while it runs, liveness and readiness are held off.
  startupProbe:
    httpGet:
      path: /healthz
      port: http
    periodSeconds: 10
    # Allow up to 5 minutes (30 x periodSeconds) to come up.
    failureThreshold: 30

  # Liveness probe for the webhook container.
  # Stays on /healthz, which only reports that the n8n process is running. A database outage
  # should drain pods from the Service via the readiness probe, not restart every pod at once.
  # To also have Kubernetes restart a pod whose DB connection never recovers, point this at
  # /healthz/readiness with a failureThreshold high enough to ride out a short blip.
  # See https://github.com/8gears/n8n-helm-chart/issues/308
  livenessProbe:
    httpGet:
      path: /healthz
      port: http
    # initialDelaySeconds: 30
    # periodSeconds: 10
    # timeoutSeconds: 5
    # failureThreshold: 6
    # successThreshold: 1

  # Readiness probe for the webhook container.
  # /healthz/readiness reflects the database connection and migration state, so a pod answering
  # "Database is not ready!" is removed from the Service endpoints. /healthz returns 200 in that
  # situation and would keep traffic flowing to a pod that cannot serve a single request.
  readinessProbe:
    httpGet:
      path: /healthz/readiness
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

  # Pod termination grace period in seconds
  terminationGracePeriodSeconds: 30

#
# Sandbox, the isolated execution environment the instance-ai module needs
#

#  n8n's instance-ai module (AI Assistant, agent code execution) runs generated code inside a
#  sandbox rather than in the n8n pod. This section connects n8n to an n8n Sandbox Service and can
#  optionally deploy one. See https://github.com/n8n-io/n8n-sandbox-service
sandbox:
  #  Set N8N_SANDBOX_SERVICE_URL and N8N_SANDBOX_SERVICE_API_KEY on the components in wireInto.
  #  This only supplies the connection; enable the feature itself through main.config, for example
  #  n8n.enabled_modules and n8n.instance_ai.sandbox.enabled. Doing it here instead would emit a
  #  container env entry, which silently overrides whatever main.config puts in the ConfigMap.
  enabled: false

  #  Also deploy the upstream n8n-sandbox-service chart as part of this release. Leave false to point
  #  n8n at a sandbox that lives elsewhere, or at a hosted provider.
  #
  #  The runner needs Docker-in-Docker privileges the chart cannot grant itself: either sysbox on the
  #  nodes, or runner.isolation=privileged with a Pod Security Admission privileged namespace. Read
  #  the Sandbox section of the README before turning this on.
  deploy: false

  #  Base URL of the sandbox API. Defaults to the API Service of the deployed subchart, so it only
  #  needs a value when deploy is false.
  url: ""

  apiKey:
    #  Secret holding the sandbox API key, which has to match the key the sandbox API accepts.
    #  Defaults to the auth Secret of the deployed subchart. Required when deploy is false.
    existingSecret: ""
    #  Key within that Secret. Empty follows the deployed subchart's auth.secretKeys.apiKeys, or
    #  api-keys when nothing is deployed.
    key: ""

  #  Which n8n components receive the sandbox connection. The AI Assistant runs in the main
  #  instance; add worker when your workflows execute sandbox-backed agent nodes.
  wireInto:
    - main

#  Values for the upstream n8n-sandbox-service subchart, rendered when sandbox.deploy is true.
#  Full reference: https://github.com/n8n-io/n8n-sandbox-service/tree/main/charts/n8n-sandbox-service
n8n-sandbox-service: {}
#  auth:
#    #  Prefer an existingSecret in production. The subchart refuses to render on placeholder values.
#    existingSecret: n8n-sandbox-auth
#  runner:
#    #  sysbox (default) needs sysbox installed on the nodes. Use privileged on clusters that cannot
#    #  install it, such as Talos, Bottlerocket, Flatcar and Fedora CoreOS.
#    isolation: sysbox
#  tls:
#    #  The API and runners speak gRPC over mutual TLS, so they need a private CA, not a public one.
#    mode: certManager
#    certManager:
#      issuerRef:
#        name: sandbox-ca
#        kind: ClusterIssuer

#
# User defined supplementary K8s manifests
#

#  Takes a list of Kubernetes manifests and merges each resource with a default metadata.labels map and
#  installs the result.
#  Use this to add any arbitrary Kubernetes manifests alongside this chart instead of kubectl and scripts.
extraManifests: []
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

# String extraManifests supports using variables directly within a string manifest.
# Templates are rendered using the context defined in the values.yaml file, enabling dynamic and flexible content customization.
extraTemplateManifests: []
#  - |
#    apiVersion: v1
#    kind: ConfigMap
#    metadata:
#      name: my-config
#    stringData:
#      image_name: {{ .Values.image.repository }}

# Official Valkey Helm Chart configuration
# https://github.com/valkey-io/valkey-helm
valkey:
  enabled: false
  # replicaCount: 1
  #
  # auth:
  #   enabled: false
  #
  # dataStorage:
  #   enabled: false
  #   requestedSize: 2Gi
```
## Sandbox for the AI Assistant

n8n's `instance-ai` module (AI Assistant, agent code execution) runs generated code inside a
sandbox instead of in the n8n pod. The `sandbox` section connects n8n to an
[n8n Sandbox Service](https://github.com/n8n-io/n8n-sandbox-service) and, with
`sandbox.deploy: true`, deploys one as a subchart in the same release.

The chart supplies only the two facts you cannot write by hand. With `sandbox.deploy: true` it
derives `N8N_SANDBOX_SERVICE_URL` from the sandbox API Service and reads `N8N_SANDBOX_SERVICE_API_KEY`
straight out of the sandbox's own Secret. With `sandbox.deploy: false` you supply both yourself,
through `sandbox.url` and `sandbox.apiKey.existingSecret`, and rendering fails until you do. The
derived URL is plain HTTP to a ClusterIP Service in the release namespace, because the upstream API
serves no TLS on that port. The key it carries in the `X-Api-Key` header is the sandbox's admin key,
so a sandbox reached across a trust boundary belongs behind a TLS ingress with an `https://` value
in `sandbox.url`. Switching the feature on stays with you, in `main.config`,
because a container environment entry would silently override whatever the ConfigMap holds:

```yaml
main:
  config:
    n8n:
      enabled_modules: "instance-ai"
      instance_ai:
        sandbox:
          enabled: true
          provider: n8n-sandbox
```

See [examples/values_sandbox.yaml](examples/values_sandbox.yaml) for a complete file.

### Cluster prerequisites

The sandbox runner is a Docker-in-Docker container. No chart can grant it the privileges it needs,
so the cluster has to be prepared first:

* **`runner.isolation: sysbox`** (the upstream default, and the recommended one) needs
  [sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-k8s.md) installed
  on the nodes. Its installer labels them `sysbox-install=yes` and registers a `sysbox-runc`
  RuntimeClass, which the runner pod then requests.
* **`runner.isolation: privileged`** is for clusters where sysbox cannot install at all, because it
  has to modify the node filesystem and containerd config: Talos, Bottlerocket, Flatcar and Fedora
  CoreOS. It needs `runner.acknowledgePrivileged: true` and the namespace labelled
  `pod-security.kubernetes.io/enforce=privileged`. **An escape from the runner container reaches the
  node.** Prefer a dedicated node pool.

  `runner.privileged.runtime.hostUsers: false` scopes those capabilities to a pod user namespace,
  which narrows the blast radius without making it a boundary. Kubernetes >= 1.33 with
  containerd >= 2.0 is necessary but *not* sufficient: the node also needs
  `user.max_user_namespaces` above 0. Talos ships it at `0`, and there the runner pod never starts
  — the pod sandbox fails with `unshare: fork/exec /proc/self/exe: no space left on device`, which
  is the kernel refusing a new user namespace, not a full disk. Check it before enabling, on a node
  from the pool the runner will schedule to, since pools can differ:

  ```console
  $ kubectl run sysctl-probe --rm -it --image=busybox --restart=Never \
      --overrides='{"spec":{"nodeName":"<node>"}}' \
      -- cat /proc/sys/user/max_user_namespaces
  ```

  Leave `hostUsers: null` when it reads `0`.
* GKE Autopilot blocks both. Run the data plane outside the cluster there
  (`dataPlane.mode: external`) and point `sandbox.url` at it.
* The API and runners speak gRPC over **mutual TLS**, so they need a *private* CA. A public ACME
  issuer such as Let's Encrypt cannot serve this; use `tls.mode: certManager` with a self-signed CA
  issuer, or `tls.mode: existingSecret` with certificates you manage.

Anything under `n8n-sandbox-service` goes to the upstream chart untouched. Its
[README](https://github.com/n8n-io/n8n-sandbox-service/tree/main/charts/n8n-sandbox-service)
is the reference for those values, including disk quotas, NetworkPolicy and ServiceMonitor.

### Licensing

The n8n Sandbox Service is covered by n8n's
[Sustainable Use License](https://github.com/n8n-io/n8n-sandbox-service/blob/main/LICENSE.md), and
its Firecracker runner requires an n8n Enterprise licence. That is a different licence from this
chart's own, so review it before deploying the subchart.

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

You can define to spawn more workers, by set scaling.worker.replicaCount to a higher
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

