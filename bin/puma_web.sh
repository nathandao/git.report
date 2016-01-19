#! /bin/sh

PUMA_WEB_RU= /var/www/service.git.report/current/config/web.ru
PUMA_CONFIG_FILE=/var/www/service.git.report/current/config/puma_web.rb
PUMA_PID_FILE=/var/www/service.git.report/shared/tmp/pids/puma_web.pid
PUMA_SOCKET=/var/www/service.git.report/shared/tmp/sockets/puma_web.sock

# check if puma process is running
puma_is_running() {
  if [ -S $PUMA_SOCKET ] ; then
    if [ -e $PUMA_PID_FILE ] ; then
      if cat $PUMA_PID_FILE | xargs pgrep -P > /dev/null ; then
        return 0
      else
        echo "No puma process found"
      fi
    else
      echo "No puma pid file found"
    fi
  else
    echo "No puma socket found"
  fi

  return 1
}

case "$1" in
  start)
    echo "Starting web puma..."
      rm -f $PUMA_SOCKET
      if [ -e $PUMA_CONFIG_FILE ] ; then
        bundle exec puma $PUMA_WEB_RU -C $PUMA_CONFIG_FILE
      else
        bundle exec puma
      fi

    echo "done"
    ;;

  stop)
    echo "Stopping web puma..."
      kill -s SIGTERM `cat $PUMA_PID_FILE`
      rm -f $PUMA_PID_FILE
      rm -f $PUMA_SOCKET

    echo "done"
    ;;

  restart)
    if puma_is_running ; then
      echo "Hot-restarting web puma..."
      kill -s SIGUSR2 `cat $PUMA_PID_FILE`

      echo "Doublechecking the process restart..."
      sleep 5
      if puma_is_running ; then
        echo "done"
        exit 0
      else
        echo "Puma web restart failed :/"
      fi
    fi

    echo "Trying cold reboot"
    bin/puma.sh start
    ;;

  *)
    echo "Usage: script/puma_web.sh {start|stop|restart}" >&2
    ;;
esac
