#!/bin/bash
URL="http://localhost/api/v1/estudiantes/notas"

echo "Monitoreando SLI: Tiempo de respuesta (Objetivo: < 500ms)"
echo "-----------------------------------------------------------------------"

while true; do
  HTTP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}" $URL)
  TIME_RESPONSE=$(curl -o /dev/null -s -w "%{time_total}" $URL)
  
  # Convertir a milisegundos
  TIME_MS=$(echo "$TIME_RESPONSE * 1000" | bc -l | cut -d'.' -f1)

  if [ "$HTTP_RESPONSE" -eq 200 ]; then
    if [ "$TIME_MS" -lt 500 ]; then
      echo -e "\e[32m[CUMPLIENDO] HTTP $HTTP_RESPONSE | Latencia: ${TIME_MS}ms - Operando en rango seguro.\e[0m"
    else
      echo -e "\e[33m[ALERTA] HTTP $HTTP_RESPONSE | Latencia: ${TIME_MS}ms - ¡EXCEDE EL SLI OBJETIVO!\e[0m"
    fi
  else
    echo -e "\e[31m[CRÍTICO] HTTP $HTTP_RESPONSE | La plataforma académica está CAÍDA.\e[0m"
  fi
  
  sleep 2
done
