{{- define "sandbox.netbirdMount" -}}
{{- if .Values.netbird.clientManagementUrl -}}
{{- $_ := set .Values.mounts "pat" (dict
      "extension" ""
      "mountPath" "/srv/netbird-pat"
      "isOneFile" true
      "subPath" false
      "mode" "0600"
      "type" (dict "secret" (dict "secretName" "netbird-pat"))) -}}
{{- end -}}
{{- end -}}
