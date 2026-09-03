{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/* Create the name of the service account to use */}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.main.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.main.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.main.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* PVC existing, emptyDir, Dynamic */}}
{{- define "n8n.pvc" -}}
{{- if or (not .Values.main.persistence.enabled) (eq .Values.main.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.main.persistence.enabled .Values.main.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.main.persistence.existingClaim }}
{{- else if and .Values.main.persistence.enabled (eq .Values.main.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}
{{- end }}
{{- end }}


{{/* Create environment variables from yaml tree */}}
{{- define "toEnvVars" -}}
    {{- $prefix := "" }}
    {{- if .prefix }}
        {{- $prefix = printf "%s_" .prefix }}
    {{- end }}
    {{- range $key, $value := .values }}
        {{- if kindIs "map" $value -}}
            {{- dict "values" $value "prefix" (printf "%s%s" $prefix ($key | upper)) "isSecret" $.isSecret | include "toEnvVars" -}}
        {{- else -}}
            {{- if $.isSecret -}}
{{ $prefix }}{{ $key | upper }}: {{ $value | toString | b64enc }}{{ "\n" }}
            {{- else -}}
{{ $prefix }}{{ $key | upper }}: {{ $value | toString | quote }}{{ "\n" }}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end }}


{{/* Validate Valkey/Redis configuration when webhooks are enabled*/}}
{{- define "n8n.validateValkey" -}}
{{- $envVars := fromYaml (include "toEnvVars" (dict "values" .Values.main.config "prefix" "")) -}}
{{- if and .Values.webhook.enabled (not $envVars.QUEUE_BULL_REDIS_HOST) -}}
{{- fail "Webhook processes rely on Valkey. Please set a Redis/Valkey host when webhook.enabled=true" -}}
{{- end -}}
{{- end -}}




{{/* Fully qualified name of the sandbox API Service.
     This mirrors the fullname helper of the upstream n8n-sandbox-service chart. That coupling is
     the price of deriving the URL for the user; re-check it against their _helpers.tpl whenever the
     dependency version in Chart.yaml moves. */}}
{{- define "n8n.sandboxApiName" -}}
{{- printf "%s-api" (include "n8n.sandboxFullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "n8n.sandboxFullname" -}}
{{- $values := default (dict) (index .Values "n8n-sandbox-service") -}}
{{- if $values.fullnameOverride -}}
{{- $values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "n8n-sandbox-service" $values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Base URL n8n uses to reach the sandbox API */}}
{{- define "n8n.sandboxUrl" -}}
{{- if .Values.sandbox.url -}}
{{- .Values.sandbox.url -}}
{{- else if .Values.sandbox.deploy -}}
{{- $values := default (dict) (index .Values "n8n-sandbox-service") -}}
{{- printf "http://%s.%s.svc:%v" (include "n8n.sandboxApiName" .) .Release.Namespace (dig "api" "service" "httpPort" 8080 $values) -}}
{{- else -}}
{{- fail "sandbox.enabled needs a sandbox to talk to: set sandbox.url, or sandbox.deploy=true to run one in this release" -}}
{{- end -}}
{{- end -}}

{{/* Secret holding the sandbox API key */}}
{{- define "n8n.sandboxSecretName" -}}
{{- if .Values.sandbox.apiKey.existingSecret -}}
{{- .Values.sandbox.apiKey.existingSecret -}}
{{- else if .Values.sandbox.deploy -}}
{{- $values := default (dict) (index .Values "n8n-sandbox-service") -}}
{{- default (printf "%s-auth" (include "n8n.sandboxFullname" .)) (dig "auth" "existingSecret" "" $values) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- fail "sandbox.enabled needs an API key: set sandbox.apiKey.existingSecret, or sandbox.deploy=true to let the subchart own the Secret" -}}
{{- end -}}
{{- end -}}

{{/* Key inside that Secret holding the API key. Follows the subchart's auth.secretKeys.apiKeys
     when the subchart owns the Secret, for the same reason the name does: a rename upstream must
     not leave the n8n pod pointing at a key that no longer exists. */}}
{{- define "n8n.sandboxSecretKey" -}}
{{- $explicit := .Values.sandbox.apiKey.key -}}
{{- if and .Values.sandbox.deploy (not .Values.sandbox.apiKey.existingSecret) -}}
{{- $sbx := default (dict) (index .Values "n8n-sandbox-service") -}}
{{- $keys := default (dict) (get (default (dict) (get $sbx "auth")) "secretKeys") -}}
{{- $upstream := default "api-keys" (get $keys "apiKeys") -}}
{{- if and $explicit (ne $explicit $upstream) -}}
{{- fail (printf "sandbox.apiKey.key %q does not exist in the Secret the sandbox subchart writes; it stores the API key under %q (n8n-sandbox-service.auth.secretKeys.apiKeys). Drop sandbox.apiKey.key to follow it" $explicit $upstream) -}}
{{- end -}}
{{- $upstream -}}
{{- else -}}
{{- default "api-keys" $explicit -}}
{{- end -}}
{{- end -}}

{{/* Connection environment for a component listed in sandbox.wireInto.
     Takes a dict with "root" (the chart context) and "extraEnv" (that component's extraEnv map).
     Only the two connection facts live here. Everything that switches the feature on belongs in
     main.config/main.secret, because a container env entry wins over envFrom and would quietly
     override the user's own value. The same two names in extraEnv would yield a duplicate env
     entry with no defined winner, so that is refused rather than resolved. */}}
{{- define "n8n.sandboxEnv" -}}
{{- $root := .root -}}
{{- range $name := list "N8N_SANDBOX_SERVICE_URL" "N8N_SANDBOX_SERVICE_API_KEY" -}}
{{- if hasKey (default (dict) $.extraEnv) $name -}}
{{- fail (printf "%s is set by the sandbox section; remove it from extraEnv or drop that component from sandbox.wireInto" $name) -}}
{{- end -}}
{{- end -}}
- name: N8N_SANDBOX_SERVICE_URL
  value: {{ include "n8n.sandboxUrl" $root | quote }}
- name: N8N_SANDBOX_SERVICE_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "n8n.sandboxSecretName" $root }}
      key: {{ include "n8n.sandboxSecretKey" $root }}
{{- end -}}

{{/* A misspelt component in sandbox.wireInto would otherwise deploy silently unwired */}}
{{- define "n8n.sandboxValidateWireInto" -}}
{{- if .Values.sandbox.enabled -}}
{{- range $component := default (list) .Values.sandbox.wireInto -}}
{{- if not (has $component (list "main" "worker" "webhook")) -}}
{{- fail (printf "sandbox.wireInto: unknown component %q; use main, worker or webhook" (toString $component)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Checksum input for a component's pod template. Takes a dict with "root" and "component".
     Everything under sandbox.* already shows in the pod template and rolls it on its own; the one
     thing the pod cannot see change is the API key inside the subchart's generated Secret, because
     Kubernetes never refreshes a secretKeyRef in a running container. So that value, and only
     that value, is hashed, and only for a component that reads it. A disabled feature contributes
     nothing, which keeps the hash of an existing release identical across the upgrade. Null-safe
     on purpose: --set n8n-sandbox-service.auth=null is a legitimate way to drop the defaults. */}}
{{- define "n8n.sandboxChecksumInput" -}}
{{- $v := .root.Values -}}
{{- if and $v.sandbox.enabled $v.sandbox.deploy (not $v.sandbox.apiKey.existingSecret) (has .component (default (list) $v.sandbox.wireInto)) -}}
{{- $auth := default (dict) (get (default (dict) (index $v "n8n-sandbox-service")) "auth") -}}
{{- if not (get $auth "existingSecret") -}}
{{- print (get (default (dict) (get $auth "generated")) "apiKeys") -}}
{{- end -}}
{{- end -}}
{{- end -}}
