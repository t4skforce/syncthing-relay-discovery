#!/bin/sh
while [ ! -f "${USER_HOME}/certs/cert.pem" ] || [ ! -f "${USER_HOME}/certs/key.pem" ]
do
  echo "waiting for certificates."
  sleep 1
done
${USER_HOME}/server/discosrv -listen=":${DISCO_PORT}" -limit-avg=${LIMIT_AVG} -limit-cache=${LIMIT_CACHE} -limit-burst=${LIMIT_BURST} -stats-file="/home/discosrv/stats" -db-dsn="file://${USER_HOME}/db/discosrv.db" -cert="${USER_HOME}/certs/cert.pem" -key="${USER_HOME}/certs/key.pem" -debug="${DEBUG}"
