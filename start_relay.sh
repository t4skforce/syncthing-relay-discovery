#!/bin/sh
${USER_HOME}/server/relaysrv -listen="0.0.0.0:${RELAY_PORT}" -status-srv="0.0.0.0:${STATUS_PORT}" -keys="${USER_HOME}/certs" -global-rate="${RATE_GLOBAL}" -per-session-rate="${RATE_SESSION}" -message-timeout="${TIMEOUT_MSG}" -network-timeout="${TIMEOUT_NET}" -ping-interval="${PING_INT}" -provided-by="${PROVIDED_BY}" -pools="${POOLS}" -debug="${DEBUG}"
