#!/usr/bin/env bash
#
# Simulates s2i build using podman = test for selected Ruby container
#
# Usage:
#
#   $ ./test_cont.sh [ARGS] [all other are passed to podman]
#
#     - you need to specify container image
#
#
# ARGS, in order:
#
#   -i    injects (after cd to copied project folder) a custom scriplet
#
#   -k    keeps the container run after the test (removes --rm)
#
# Example:
#
#   $ ./test_cont.sh registry.access.redhat.com/ubi8/ruby-26
#

export http_proxy=

[[ "$1" == "-d" ]] && {
  DEBUG="$1"
  shift
  set -x
  :
} || DEBUG=

export http_proxy=

[[ "$1" == "-i" ]] && {
  inject=" && { $2 ; }"
  shift 2
  :
} || inject=

[[ "$1" == "-k" ]] && {
  rm=
  shift
  :
} || rm=' --rm'

[[ "${1:0:1}" == '-' ]] && exit 2

m='/my-app'

podman run -v"$PWD:${m}/:Z,ro" -ti$rm "$@" bash -c "
    echo
    set -x
    ruby -v
    cp -r ${m}/ /tmp \
      && cd /tmp${m}${inject} \
      && bundle config --local deployment 'true' \
      && bundle config --local without "development:test" \
      && bundle install --path vendor \
      && {
        timeout 10 bundle exec rackup
        R=\$?
        cat Gemfile.lock
        [[ 124 -eq \$R ]] && exit 0
      }
    exit 1
  "
