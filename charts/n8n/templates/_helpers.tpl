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

{{/*
Selector labels
*/}}
{{- define "n8n.deploymentPodEnvironments" -}}
{{- range $key, $value := .Values.extraEnv }}
- name: {{ $key }}
  value: {{ $value | quote}}
{{ end }}
{{- range $key, $value := .Values.extraEnvSecrets }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $value.name | quote }}
      key: {{ $value.key | quote }}
{{ end }}
- name: "N8N_PORT" #! we better set the port once again as ENV Var, see: https://community.n8n.io/t/default-config-is-not-set-or-the-port-to-be-more-precise/3158/3?u=vad1mo
  value: {{ get .Values.config "port" | default "5678" | quote }}
{{- if .Values.n8n.encryption_key }}
- name: "N8N_ENCRYPTION_KEY"
  valueFrom:
    secretKeyRef:
      key:  N8N_ENCRYPTION_KEY
      name: {{ include "n8n.fullname" . }}
{{- end }}
{{- if or .Values.config .Values.secret }}
- name: "N8N_CONFIG_FILES"
  value: {{ include "n8n.configFiles" . | quote }}
{{ end }}
{{- if .Values.scaling.enabled }}
- name: "QUEUE_BULL_REDIS_HOST"
  {{- if .Values.scaling.redis.host }}
  value: "{{ .Values.scaling.redis.host }}"
  {{ else }}
  value: "{{ .Release.Name }}-redis-master"
  {{ end }}
- name: "EXECUTIONS_MODE"
  value: "queue"
{{ end }}
{{- if .Values.scaling.redis.password }}
- name: "QUEUE_BULL_REDIS_PASSWORD"
  value: "{{ .Values.scaling.redis.password }}"
{{ end }}
{{- if .Values.scaling.webhook.enabled }}
- name: "N8N_DISABLE_PRODUCTION_MAIN_PROCESS"
  value: "true"
{{ end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Create a list of config files for n8n */}}
{{- define "n8n.configFiles" -}}
    {{- $conf_val := "" }}
    {{- $sec_val  := "" }}
    {{- $separator  := "" }}
    {{- if .Values.config }}
        {{- $conf_val = "/n8n-config/config.json" }}
    {{- end }}
    {{- if or .Values.secret .Values.existingSecret }}
        {{- $sec_val = "/n8n-secret/secret.json" }}
    {{- end }}
    {{- if and .Values.config (or .Values.secret .Values.existingSecret) }}
        {{- $separator  = "," }}
    {{- end }}
    {{- print $conf_val $separator $sec_val }}
{{- end }}


{{/* PVC existing, emptyDir, Dynamic */}}
{{- define "n8n.pvc" -}}
{{- if or (not .Values.persistence.enabled) (eq .Values.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.persistence.enabled .Values.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.persistence.existingClaim }}
{{- else if and .Values.persistence.enabled (eq .Values.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}
{{- end }}
{{- end }}
