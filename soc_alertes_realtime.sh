#!/bin/bash
tail -Fn0 /var/log/audit/audit.log | \
while read line; do

  # ALERTA 1 – docker sospitós (amb muntatge de /)
  if echo "$line" | grep -q "key=docker-sospitos"; then
    if echo "$line" | grep -q "/:/mnt"; then
      echo "[ALERTA SOC] Docker amb muntatge de / detectat! $(date)" >> /var/log/alertes_soc.log
    fi
  fi

  # ALERTA 2 – execució de shell (sh) des de context inesperat
  if echo "$line" | grep -q "key=shell-inesperada"; then
    parent_pid=$(echo "$line" | grep -oP 'ppid=\K[0-9]+')
    if [ -n "$parent_pid" ]; then
      parent_name=$(ps -p "$parent_pid" -o comm=)
      if echo "$parent_name" | grep -q "nano"; then
        echo "[ALERTA SOC] Execució de shell des de nano detectada! $(date)" >> /var/log/alertes_soc.log
      fi
    fi
  fi

done
