#\!/bin/sh
find_tty ()
{
  for n in $(pidof make); do
    TTY="$(basename "$(realpath /proc/$n/fd/0)" | grep '^[0-9]\+$')"
    [ -n "$TTY" ] && return
  done
}

if [ -n "$1" ]; then
  TTY=$1
else
  find_tty
fi
[ -n "${TTY}" ] && TTY="t${TTY}"
THERMALFILE="/sys/devices/virtual/thermal/thermal_zone0/temp"
CMD="clear; echo \$(uptime)"
[ -f "${THERMALFILE}" ] && \
  CMD="${CMD}, temp: \$(sed -e 's/\([0-9]\{2\}\)[0-9]$/,\1/' ${THERMALFILE})°C"
CMD="${CMD}; free -h; ps -o '%cpu %mem args' -H ${TTY}"
exec watch -tc "${CMD}"
