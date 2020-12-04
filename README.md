# n8n Helm Chart for Kubernetes

[n8n](https://github.com/n8n-io/n8n) is an extendable workflow automation tool.


The Helm chart source code location is [github.com/8gears/n8n-helm-chart](https://github.com/8gears/n8n-helm-chart)
 

8gears Chart Museum location is: [8gears.container-registry.com/harbor/projects/1/helm-charts/n8n/versions/0.1.0](https://8gears.container-registry.com/harbor/projects/1/helm-charts/n8n/versions/0.1.0)


## Requirements

Before you start make sure you have the following dependencies ready and working: 

- Helm > 3
- Postgres DB | MongoDB | MySQL | Embedded SQLite 
- Helmfile (Optional)

## Configuration
The `values.yaml` file is divided into a n8n specific configuration section, and a Kubernetes deployment specific section. 

The shown values represent Helm defaults not application defaults. The comments behind the values provide a description and display the application default.

Every possible n8n config can be set that are also described in the: [n8n configuration options](https://github.com/n8n-io/n8n/blob/master/packages/cli/config/index.ts).

These n8n config options should be attached to Secret or Config. 
You decide what should be a secret and what should be a config the options are the same.

```yaml

database:
  type:   # Type of database to use - Other possible types ['sqlite', 'mariadb', 'mongodb', 'mysqldb', 'postgresdb'] - default: sqlite
  tablePrefix:      # Prefix for table names - default: ''
  mongodb:
    connectionUrl:  # MongoDB Connection URL - default: mongodb://user:password@localhost:27017/database
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

# Typical Example of a config in combination with a secret.
# config:
#    database:
#      type: postgresdb
#      postgresdb:        
#        host: 192.168.0.52 
# secret: 
#    database:      
#      postgresdb:        
#        password: 'big secret'



### The Kubernetes related Part
``` 

## Chart Deployment


```shell script

helm repo add  --username='robot$helmcli' --password="xxx" 8gears https://8gears.container-registry.com/chartrepo/library 
helm push --username='robot$helmcli' --password="$PASSWD" . 8gears

```
