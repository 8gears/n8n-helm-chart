# Example Values Files 

this directory contains some example values
for to help you get started with a setup for your particular use case.


## Examples

* values_local.yaml - n8n on local kind/k3s cluster for testing on localhost
* aws - n8n on AWS with EKS, ingress-nginx
* simple-prod -  simple production setup with AWS
* values_stateful.yaml - n8n deployed as a StatefulSet with individual persistent volumes per replica

## Render Examples

```shell
helm template n8n charts/n8n -f examples/values_full.yaml > manifests.yaml
```


## Test Examples

If you want to text or deploy this examples with postgresdb, we recommend the use
cloudnative-pg.

The `full` and `small-prod` examples already deploy a database instance.

See [installation guide](https://cloudnative-pg.io/documentation/1.26/installation_upgrade/) for all details.

```shell
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml
kubectl rollout status deployment \
  -n cnpg-system cnpg-controller-manager
```
