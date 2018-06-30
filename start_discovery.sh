#!/bin/sh
while [ ! -f "${USER_HOME}/certs/cert.pem" ] || [ ! -f "${USER_HOME}/certs/key.pem" ]
do
  echo "waiting for certificates."
  sleep 1
done
${USER_HOME}/server/discosrv -listen=":${DISCO_PORT}" -stats-file="/home/discosrv/stats" -db-dir="${USER_HOME}/db/discosrv.db" -cert="${USER_HOME}/certs/cert.pem" -key="${USER_HOME}/certs/key.pem" ${DISCO_OPTS}
