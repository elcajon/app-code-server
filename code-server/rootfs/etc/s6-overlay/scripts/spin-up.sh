#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant App: Code Server
# Runs initialization scripts
# ==============================================================================

/etc/s6-overlay/scripts/01-vs-code-server
/etc/s6-overlay/scripts/01-vs-mosquitto
/etc/s6-overlay/scripts/01-vs-mysql
/etc/s6-overlay/scripts/01-vs-user
/etc/s6-overlay/scripts/02-docker