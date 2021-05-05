#!/usr/bin/bash

[[ "$1" == "-i" ]] && {
  inject=" && { $2 ; }"
  shift 2
  :
} || inject=

m='/my-app'

podman run -v"$PWD:${m}/:Z,ro" -ti --rm "$@" bash -c "set -x; cp -r ${m}/ /tmp && cd /tmp${m}${inject} && bundle install --path vendor && { timeout 10 bundle exec rackup; R=\$?; cat Gemfile.lock; [[ 124 -eq \$R ]] && exit 0; }; exit 1"
