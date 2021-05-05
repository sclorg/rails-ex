#!/usr/bin/bash

export http_proxy=

tst="$(readlink -e "$(dirname "$0")/test_cont.sh")"
[[ -x "$tst" ]] || exit 1

for x in 2{5..7} 3{0..1}; do
  $tst "registry.access.redhat.com/ubi8/ruby-${x}" \
    || break
done
