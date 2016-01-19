#!/usr/bin/env puma

environment ENV['RACK_ENV'] || 'production'

daemonize true

pidfile "/var/www/service.git.report/shared/tmp/pids/puma_web.pid"
stdout_redirect "/var/www/service.git.report/shared/tmp/log/stdout", "/var/www/service.git.report/shared/tmp/log/stderr"

threads 0, 16

bind "unix:///var/www/service.git.report/shared/tmp/sockets/puma_web.sock"
