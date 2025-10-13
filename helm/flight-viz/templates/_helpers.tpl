{{/*
Expand the name of the chart.
*/}}
{{- define "flight-viz.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "flight-viz.fullname" -}}
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
{{- define "flight-viz.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flight-viz.labels" -}}
helm.sh/chart: {{ include "flight-viz.chart" . }}
{{ include "flight-viz.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flight-viz.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flight-viz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL fullname
*/}}
{{- define "flight-viz.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "flight-viz.fullname" .) }}
{{- end }}

{{/*
Backend fullname
*/}}
{{- define "flight-viz.backend.fullname" -}}
{{- printf "%s-backend" (include "flight-viz.fullname" .) }}
{{- end }}

{{/*
Frontend fullname
*/}}
{{- define "flight-viz.frontend.fullname" -}}
{{- printf "%s-frontend" (include "flight-viz.fullname" .) }}
{{- end }}
