#!/bin/bash
export LC_ALL=C
export LANG=C
[ -d logs ] || exit 1
mata ()
{
  echo -ne "\033]0;${USER}@${HOSTNAME}:${PWD}\007"
  [ -z "$!" ] || \
  kill $! && \
  wait $! &> /dev/null
}

find_tty ()
{
  for n in $(pidof -x do_it_all.sh make); do
    TTY="$(basename "$(realpath /proc/$n/fd/0)" | grep '^[0-9]\+$')"
    [ -n "$TTY" ] && return
  done
}

acha_log()
{
  PID="$(ps -o pid,args -H ${TTY} | grep -E '[0-9]+[[:space:]]*tee.*logs' | head -n1 | sed 's/^[[:space:]]*\([0-9]\+\).*$/\1/')"
  if [ -n "${PID}" ]; then
    file="$(cat /proc/${PID}/cmdline 2>/dev/null | sed -zn 2p | tr '\000' '\n')"
    [ -n "$file" ] && \
      FILE="$(ls -1 -G -g -n $file | sed 's/.*\(logs.*\)$/\1/')"
  else
    echo "Can't find a PID TTY=${TTY}" >&2 && ps -o pid,args -H ${TTY} >&2
  fi
}

if [ -n "$1" ]; then
  TTY=$1
else
  find_tty
fi
[ -n "${TTY}" ] && TTY="t${TTY}"

trap mata EXIT
OLDFILE=
PRIMEIRAVEZ=1
while { [ ${PRIMEIRAVEZ} = 1 ] || pidof -x do_it_all.sh make; } >/dev/null 2>&1; do
  PRIMEIRAVEZ=0
  acha_log
  if [ "${FILE}" != "${OLDFILE}" ]; then
    [ -z "${OLDFILE}" ] || mata
    echo -ne "\033]0;${USER}@${HOSTNAME}:${PWD}/${FILE}\007"
    tail -fn 5000 "${FILE}" & 2>/dev/null
    OLDFILE="${FILE}"
  fi
  sleep 2
done
