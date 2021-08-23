# n8n Helm Chart for Kubernetes

[n8n](https://github.com/n8n-io/n8n) is an extendable workflow automation tool.

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/open-8gears)](https://artifacthub.io/packages/search?repo=open-8gears)

The Helm chart source code location is [github.com/8gears/n8n-helm-chart](https://github.com/8gears/n8n-helm-chart)


8gears Chart Museum location is: [8gears.container-registry.com/harbor/projects/1/helm-charts/n8n/versions](https://8gears.container-registry.com/harbor/projects/1/helm-charts/n8n/versions)


## Requirements

Before you start make sure you have the following dependencies ready and working:

- Helm > 3
- Postgres DB | MySQL | Embedded SQLite
- Helmfile (Optional)

## Configuration
The `values.yaml` file is divided into a n8n specific configuration section, and a Kubernetes deployment specific section.

The shown values represent Helm defaults not application defaults. The comments behind the values provide a description and display the application default.

Every possible n8n config can be set that are also described in the: [n8n configuration options](https://github.com/n8n-io/n8n/blob/master/packages/cli/config/index.ts).

These n8n config options should be attached to Secret or Config.
You decide what should be a secret and what should be a config the options are the same.

```yaml

database:
  type:   # Type of database to use - Other possible types ['sqlite', 'mariadb', 'mysqldb', 'postgresdb'] - default: sqlite
  tablePrefix:      # Prefix for table names - default: ''
  postgresdb:
    database:       # PostgresDB Database - default: n8n
    host:           # PostgresDB Host - default: localhost
    password:       # PostgresDB Password - default: ''
    port:           # PostgresDB Port - default: 5432
    user:           # PostgresDB User - default: root
    schema:         # PostgresDB Schema - default: public
    ssl:
      ca:             # SSL certificate authority - default: ''
      cert:           # SSL certificate - default: ''
      key:            # SSL key - default: ''
      rejectUnauthorized:    # If unauthorized SSL connections should be rejected - default: true
  mysqldb:
    database:        # MySQL Database - default: n8n
    host:            # MySQL Host - default: localhost
    password:        # MySQL Password - default: ''
    port:            # MySQL Port - default: 3306
    user:            # MySQL User - default: root
credentials:
  overwrite:
    data:        # Overwrites for credentials - default: "{}"
    endpoint:    # Fetch credentials from API - default: ''

executions:
  process:              # In what process workflows should be executed - possible values [main, own] - default: own
  timeout:              # Max run time (seconds) before stopping the workflow execution - default: -1
  maxTimeout:           # Max execution time (seconds) that can be set for a workflow individually - default: 3600
  saveDataOnError:      # What workflow execution data to save on error - possible values [all , none] - default: all
  saveDataOnSuccess:    # What workflow execution data to save on success - possible values [all , none] - default: all
  saveDataManualExecutions:    # Save data of executions when started manually via editor - default: false
  pruneData:            # Delete data of past executions on a rolling basis - default: false
  pruneDataMaxAge:      # How old (hours) the execution data has to be to get deleted - default: 336
  pruneDataTimeout:     # Timeout (seconds) after execution data has been pruned - default: 3600
generic:
  timezone:       # The timezone to use - default: America/New_York
path:           # Path n8n is deployed to - default: "/"
host:           # Host name n8n can be reached - default: localhost
port:           # HTTP port n8n can be reached - default: 5678
listen_address: # IP address n8n should listen on - default: 0.0.0.0
protocol:       # HTTP Protocol via which n8n can be reached - possible values [http , https] - default: http
ssl_key:        # SSL Key for HTTPS Protocol - default: ''
ssl_cert:       # SSL Cert for HTTPS Protocol - default: ''
security:
  excludeEndpoints: # Additional endpoints to exclude auth checks. Multiple endpoints can be separated by colon - default: ''
  basicAuth:
    active:     # If basic auth should be activated for editor and REST-API - default: false
    user:       # The name of the basic auth user - default: ''
    password:   # The password of the basic auth user - default: ''
    hash:       # If password for basic auth is hashed - default: false
  jwtAuth:
    active:               # If JWT auth should be activated for editor and REST-API - default: false
    jwtHeader:            # The request header containing a signed JWT - default: ''
    jwtHeaderValuePrefix: # The request header value prefix to strip (optional) default: ''
    jwksUri:              # The URI to fetch JWK Set for JWT authentication - default: ''
    jwtIssuer:            # JWT issuer to expect (optional) - default: ''
    jwtNamespace:         # JWT namespace to expect (optional) -  default: ''
    jwtAllowedTenantKey:  # JWT tenant key name to inspect within JWT namespace (optional) - default: ''
    jwtAllowedTenant:     # JWT tenant to allow (optional) - default: ''
endpoints:
  rest:             # Path for rest endpoint  default: rest
  webhook:          # Path for webhook endpoint  default: webhook
  webhookTest:      # Path for test-webhook endpoint  default: webhook-test
externalHookFiles:  # Files containing external hooks. Multiple files can be separated by colon - default: ''
nodes:
  exclude:          # Nodes not to load - default: "[]"
  errorTriggerType: # Node Type to use as Error Trigger - default: n8n-nodes-base.errorTrigger

```


### Values


```yaml
# The n8n related part of the config


config: # Dict with all n8n config options
secret: # Dict with all n8n config options, unlike config the values here will end up in a secret.
##
##
## Common Kubernetes Config Settings
persistence:
  ## If true, use a Persistent Volume Claim, If false, use emptyDir
  ##
  enabled: false
  type: emptyDir # what type volume, possible options are [existing, emptyDir, dynamic] dynamic for Dynamic Volume Provisioning, existing for using an existing Claim
  ## Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  # storageClass: "-"
  ## PVC annotations
  #
  # If you need this annotation include it under values.yml file and pvc.yml template will add it.
  # This is not maintained at Helm v3 anymore.
  # https://github.com/8gears/n8n-helm-chart/issues/8
  #
  # annotations:
  #   helm.sh/resource-policy: keep
  ## Persistent Volume Access Mode
  ##
  accessModes:
    - ReadWriteOnce
  ## Persistent Volume size
  ##
  size: 1Gi
  ## Use an existing PVC
  ##
  # existingClaim:

# Set additional environment variables on the Deployment
extraEnv: {}
# Set this if running behind a reverse proxy and the external port is different from the port n8n runs on
#   WEBHOOK_TUNNEL_URL: "https://n8n.myhost.com/

replicaCount: 1

image:
  repository: n8nio/n8n
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

imagePullSecrets: [ ]
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: { }
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

podAnnotations: { }

podSecurityContext: { }
# fsGroup: 2000

securityContext: { }
  # capabilities:
  #   drop:
  #   - ALL
# readOnlyRootFilesystem: true
# runAsNonRoot: true
# runAsUser: 1000

service:
  type: ClusterIP
  port: 80
  annotations: {}

ingress:
  enabled: false
  annotations: { }
  # kubernetes.io/ingress.class: nginx
  # kubernetes.io/tls-acme: "true"
  hosts:
    - host: chart-example.local
      paths: [ ]
  tls: [ ]
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

resources: { }
  # We usually recommend not to specify default resources and to leave this as a conscious
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

nodeSelector: { }

tolerations: [ ]

affinity: { }
```

# Typical Values Example
A typical example of a config in combination with a secret.


```yaml
# values.yaml

config:
  database:
    type: postgresdb
    postgresdb:
      host: 192.168.0.52
secret:
  database:
    postgresdb:
      password: 'big secret'

```

## Chart Deployment


```shell script

helm repo add  --username='robot$helmcli' --password="$PASSWD" open-8gears https://8gears.container-registry.com/chartrepo/library
helm push --username='robot$helmcli' --password="$PASSWD" . open-8gears

```
