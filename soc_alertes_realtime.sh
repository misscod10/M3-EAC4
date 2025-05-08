#!/bin/bash
tail -Fn0 /var/log/audit/audit.log | \
while read line; do

  # ALERTA: Execució de runc com root però des d’un usuari no root
  if echo "$line" | grep -q "exe=\"/usr/bin/runc\"" && echo "$line" | grep -q "uid=0" && echo "$line" | grep -qv "auid=0"; then
    echo "[ALERTA SOC] Execució de contenidor amb escalada detectada! UID=0 però AUID≠0 – $(date)" >> /home/alumn/alertes_soc.log
  fi

  # ALERTA 2: Execució de shell des de nano
  if echo "$line" | grep -q "key=shell-inesperada"; then
    parent_pid=$(echo "$line" | grep -oP 'ppid=\K[0-9]+')
    if [ -n "$parent_pid" ]; then
      parent_name=$(ps -p "$parent_pid" -o comm=)
      if echo "$parent_name" | grep -q "nano"; then
        echo "[ALERTA SOC] Execució de shell des de nano detectada! $(date)" >> /home/alumn/alertes_soc.log
      fi
    fi
  fi

done

