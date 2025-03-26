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

{{/* PVC existing, emptyDir, Dynamic for main component */}}
{{- define "n8n.pvc" -}}
{{- if or (not .Values.main.persistence.enabled) (eq .Values.main.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.main.persistence.enabled .Values.main.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.main.persistence.existingClaim }}
{{- else if and .Values.main.persistence.enabled (eq .Values.main.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}-main
{{- end }}
{{- end }}

{{/* PVC existing, emptyDir, Dynamic for webhook component */}}
{{- define "n8n.webhook.pvc" -}}
{{- if or (not .Values.webhook.persistence.enabled) (eq .Values.webhook.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.webhook.persistence.enabled .Values.webhook.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.webhook.persistence.existingClaim }}
{{- else if and .Values.webhook.persistence.enabled (eq .Values.webhook.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}-webhook
{{- end }}
{{- end }}

{{/* PVC existing, emptyDir, Dynamic for worker component */}}
{{- define "n8n.worker.pvc" -}}
{{- if or (not .Values.worker.persistence.enabled) (eq .Values.worker.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.worker.persistence.enabled .Values.worker.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.worker.persistence.existingClaim }}
{{- else if and .Values.worker.persistence.enabled (eq .Values.worker.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}-worker
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
{{- if and .Values.webhook.enabled (not .Values.valkey.enabled) -}}
{{- fail "Webhook processes rely on Valkey. Please set valkey.enabled=true when webhook.enabled=true" -}}
{{- end -}}
{{- end }}
