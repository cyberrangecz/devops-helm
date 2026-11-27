{{- /*
Renders one sandbox-service CronJob.
Takes: root (the chart context), name (the CronJob name), command (the manage.py subcommand),
cron (the kind's values block).
*/ -}}
{{- define "sandbox.cronjob" -}}
{{- $root := .root -}}
{{- $cron := .cron -}}
{{- include "sandbox.netbirdMount" $root -}}
{{- $cronValues := deepCopy $root.Values }}
{{- $_ := set $cronValues "mounts" (omit $root.Values.mounts "ansible-runner-vol") }}
{{- $labels := dict "name" .name "chart" $root.Chart "release" $root.Release "extraLabels" $root.Values.extraLabels }}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ .name }}
  labels: {{- include "common.labels" $labels | nindent 4 }}
spec:
  schedule: {{ $cron.schedule | quote }}
  suspend: {{ $cron.suspend }}
  startingDeadlineSeconds: {{ $cron.startingDeadlineSeconds }}
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: {{ $cron.successfulJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $cron.failedJobsHistoryLimit }}
  jobTemplate:
    spec:
      backoffLimit: 0
      activeDeadlineSeconds: {{ $cron.activeDeadlineSeconds }}
      template:
        metadata:
          labels: {{- include "common.labels" $labels | nindent 12 }}
        spec:
          serviceAccountName: sandbox-service
          restartPolicy: Never
          {{- if $root.Values.global.imageCredentials.username }}
          imagePullSecrets:
            - name: github-auth-secret
          {{- end }}
{{- include "common.deployment.containers" (dict "name" .name "Values" $cronValues "command" "sh" "args" (printf "[\"-c\",\"update-ca-certificates && python3 manage.py %s\"]" .command) "portsDisabled" true) | indent 4 }}
{{- with $cron.resources }}
              resources: {{- toYaml . | nindent 16 }}
{{- end }}
{{- include "common.deployment.volumes" (dict "Values" $cronValues) | indent 4 }}
{{- end -}}
