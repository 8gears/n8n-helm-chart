# n8n

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.74.1](https://img.shields.io/badge/AppVersion-1.74.1-informational?style=flat-square)

A Kubernetes Helm chart for n8n a free and open fair-code licensed node based Workflow Automation Tool. Easily automate tasks across different services.

**Homepage:** <https://github.com/8gears/n8n-helm-chart>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| 8gears | <contact@8gears.com> | <https://github.com/8gears> |
| n8n | <_@8gears.com> | <https://github.com/n8n-io> |

## Source Code

* <https://github.com/n8n-io/n8n>
* <https://n8n.io/>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | valkey | 2.2.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"n8nio/n8n"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"workflow.example.com"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls[0].hosts[0] | string | `"workflow.example.com"` |  |
| ingress.tls[0].secretName | string | `"host-domain-cert"` |  |
| n8n.affinity | object | `{}` |  |
| n8n.autoscaling.enabled | bool | `false` |  |
| n8n.autoscaling.maxReplicas | int | `100` |  |
| n8n.autoscaling.minReplicas | int | `1` |  |
| n8n.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| n8n.command | list | `[]` |  |
| n8n.config.n8n.encryption_key | string | `nil` |  |
| n8n.deploymentStrategy.type | string | `"Recreate"` |  |
| n8n.initContainers | list | `[]` |  |
| n8n.lifecycle | object | `{}` |  |
| n8n.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| n8n.livenessProbe.httpGet.port | string | `"http"` |  |
| n8n.nodeSelector | object | `{}` |  |
| n8n.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| n8n.persistence.enabled | bool | `false` |  |
| n8n.persistence.size | string | `"1Gi"` |  |
| n8n.persistence.type | string | `"emptyDir"` |  |
| n8n.podAnnotations | object | `{}` |  |
| n8n.podLabels | object | `{}` |  |
| n8n.podSecurityContext.fsGroup | int | `1000` |  |
| n8n.podSecurityContext.runAsGroup | int | `1000` |  |
| n8n.podSecurityContext.runAsNonRoot | bool | `true` |  |
| n8n.podSecurityContext.runAsUser | int | `1000` |  |
| n8n.readinessProbe.httpGet.path | string | `"/healthz"` |  |
| n8n.readinessProbe.httpGet.port | string | `"http"` |  |
| n8n.replicaCount | int | `1` |  |
| n8n.resources | object | `{}` |  |
| n8n.secret | string | `nil` |  |
| n8n.securityContext | object | `{}` |  |
| n8n.service.annotations | object | `{}` |  |
| n8n.service.port | int | `80` | Service port |
| n8n.service.type | string | `"ClusterIP"` | Service types allow you to specify what kind of Service you want. E.g., ClusterIP, NodePort, LoadBalancer, ExternalName |
| n8n.serviceAccount.annotations | object | `{}` |  |
| n8n.serviceAccount.create | bool | `true` |  |
| n8n.serviceAccount.name | string | `""` |  |
| n8n.tolerations | list | `[]` |  |
| nameOverride | string | `nil` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.enabled | bool | `false` |  |
| redis.master.persistence.enabled | bool | `true` |  |
| redis.master.persistence.existingClaim | string | `""` |  |
| redis.master.persistence.size | string | `"2Gi"` |  |
| resources | list | `[]` |  |
| templates | list | `[]` |  |
| webhook.affinity | object | `{}` |  |
| webhook.autoscaling.enabled | bool | `false` |  |
| webhook.autoscaling.maxReplicas | int | `100` |  |
| webhook.autoscaling.minReplicas | int | `1` |  |
| webhook.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| webhook.command | list | `[]` |  |
| webhook.commandArgs | list | `[]` |  |
| webhook.deploymentStrategy.type | string | `"Recreate"` |  |
| webhook.enabled | bool | `false` |  |
| webhook.fullnameOverride | string | `""` |  |
| webhook.initContainers | list | `[]` |  |
| webhook.lifecycle | object | `{}` |  |
| webhook.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| webhook.livenessProbe.httpGet.port | string | `"http"` |  |
| webhook.nameOverride | string | `""` |  |
| webhook.nodeSelector | object | `{}` |  |
| webhook.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| webhook.persistence.enabled | bool | `false` |  |
| webhook.persistence.size | string | `"1Gi"` |  |
| webhook.persistence.type | string | `"emptyDir"` |  |
| webhook.podAnnotations | object | `{}` |  |
| webhook.podLabels | object | `{}` |  |
| webhook.podSecurityContext.fsGroup | int | `1000` |  |
| webhook.podSecurityContext.runAsGroup | int | `1000` |  |
| webhook.podSecurityContext.runAsNonRoot | bool | `true` |  |
| webhook.podSecurityContext.runAsUser | int | `1000` |  |
| webhook.readinessProbe.httpGet.path | string | `"/healthz"` |  |
| webhook.readinessProbe.httpGet.port | string | `"http"` |  |
| webhook.replicaCount | int | `1` |  |
| webhook.resources | object | `{}` |  |
| webhook.securityContext | object | `{}` |  |
| webhook.service.annotations | object | `{}` |  |
| webhook.service.port | int | `80` | Service port |
| webhook.service.type | string | `"ClusterIP"` | Service types allow you to specify what kind of Service you want. E.g., ClusterIP, NodePort, LoadBalancer, ExternalName |
| webhook.serviceAccount.annotations | object | `{}` |  |
| webhook.serviceAccount.create | bool | `true` |  |
| webhook.serviceAccount.name | string | `""` |  |
| webhook.tolerations | list | `[]` |  |
| worker.affinity | object | `{}` |  |
| worker.autoscaling.enabled | bool | `false` |  |
| worker.autoscaling.maxReplicas | int | `100` |  |
| worker.autoscaling.minReplicas | int | `1` |  |
| worker.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| worker.command | list | `[]` |  |
| worker.commandArgs | list | `[]` |  |
| worker.concurrency | int | `2` |  |
| worker.count | int | `2` |  |
| worker.deploymentStrategy.type | string | `"Recreate"` |  |
| worker.enabled | bool | `false` |  |
| worker.initContainers | list | `[]` |  |
| worker.lifecycle | object | `{}` |  |
| worker.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| worker.livenessProbe.httpGet.port | string | `"http"` |  |
| worker.nodeSelector | object | `{}` |  |
| worker.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| worker.persistence.enabled | bool | `false` |  |
| worker.persistence.size | string | `"1Gi"` |  |
| worker.persistence.type | string | `"emptyDir"` |  |
| worker.podAnnotations | object | `{}` |  |
| worker.podLabels | object | `{}` |  |
| worker.podSecurityContext.fsGroup | int | `1000` |  |
| worker.podSecurityContext.runAsGroup | int | `1000` |  |
| worker.podSecurityContext.runAsNonRoot | bool | `true` |  |
| worker.podSecurityContext.runAsUser | int | `1000` |  |
| worker.readinessProbe.httpGet.path | string | `"/healthz"` |  |
| worker.readinessProbe.httpGet.port | string | `"http"` |  |
| worker.replicaCount | int | `1` |  |
| worker.resources | object | `{}` |  |
| worker.securityContext | object | `{}` |  |
| worker.service.annotations | object | `{}` |  |
| worker.service.port | int | `80` | Service port |
| worker.service.type | string | `"ClusterIP"` | Service types allow you to specify what kind of Service you want. E.g., ClusterIP, NodePort, LoadBalancer, ExternalName |
| worker.serviceAccount.annotations | object | `{}` |  |
| worker.serviceAccount.create | bool | `true` |  |
| worker.serviceAccount.name | string | `""` |  |
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
