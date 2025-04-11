{{/* 
Namespace from Values or Release Namespace 
*/}}
{{- define "grafana-operator.ns" -}}
{{- if .Values.namespace }}
{{- .Values.namespace | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/* 
Full name for resources 
*/}}
{{- define "grafana-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "grafana-operator.ns" .) .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}