#!/usr/bin/bash

tst="$(readlink -e "$(dirname "$0")/test_cont.sh")"
[[ -x "$tst" ]] || exit 1

for x in 2{5..7} 30; do
  $tst "registry.access.redhat.com/ubi8/ruby-${x}" \
    || break
done
