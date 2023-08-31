#!/usr/bin/env bash
#
# Runs the s2i build tests (using test_cont.sh) for all RH Ruby containers
#
# Usage:
#
#   $ ./test_ubi.sh
#
#   (no args)
#


export http_proxy=

tst="$(readlink -e "$(dirname "$0")/test_cont.sh")"
[[ -x "$tst" ]] || exit 1

for x in 25 27 3{0..1}; do
  $tst "registry.access.redhat.com/ubi8/ruby-${x}" \
    || break
done
