##!/usr/bin/env bash
#
# Refreshes Gemfile.lock using `test_cont.sh` container build.
#
# Description:
#
#   - Creates Gemfile.lock backup
#   - Generates lock file (output from test_cont.sh)
#     - Injects platform modifications (bundle lock ...)
#     - Subsequently; manually drops BUNDLED_WITH
#     - and replaces 'x86_64-linux' with 'ruby' (for various arches)
#     - Writes result into Gemfile.lock (and on output)
#   - Tests the lock file for changes; subsequent run
#     - build without platform modifications (no bundle lock ...)
#     - Fails if there are any.
#
#
# Usage:
#
#   $ ./refresh_lock.sh [ARGS] CONTAINER_IMAGE
#
#
# ARGS, in order:
#
#   -d    Debug mode
#
#   -n    Do not check generated lock validity (=builds an app)
#
# Example:
#
#   $ ./refresh_lock.sh registry.access.redhat.com/ubi8/ruby-30
#

set -e
set -o pipefail
bash -n "$0"

## Methods
abort () {
  echo "Error:" "$@" >&2
  exit 1
}

run () {
  LOG="$(
      ${tst} $DEBUG "$@" 2>&1 \
        | tee -a /dev/stderr
    )"

  getlock <<< "$LOG" \
    || \
    abort "Failed to run the app."
}

getlock () {
  local d=cat
  local lock=
  local l=2

  lock="$(
      grep -A 10000 "^+ cat ${lck}" \
        | tail -n +2
    )"

  [[ -n "$DEBUG" ]] && echo "$lock" >&2

  grep -q "^BUNDLED WITH" <<< "$lock" && {
    l=4
  }

  echo "$lock" \
    | head -n -$l \
    | sed \
      -e 's/x86_64-linux/ruby/g' \
      -e 's|\r||g'
}

lll () {
  echo -e '\n=================================================================\n'
}


## Vars
lck=Gemfile.lock
export http_proxy=

# Let's try removing x86_64 platform from lock
plt='bundle lock --add-platform ruby ||: ; bundle lock --remove-platform x86_64-linux ||: '

# Test script can actually be used for lock generation as well
tst="$(readlink -e "$(dirname "$0")/test_cont.sh")"
[[ -x "$tst" ]] || abort "Could not find or run 'test_cont.sh', path: $tst"


## Args
[[ "$1" == '-d' ]] && {
  DEBUG="$1"
  set -x
  shift
  :
} || DEBUG=

[[ "$1" == '-n' ]] && {
  NOCHECK="$1"
  shift
  :
} || NOCHECK=

[[ "${1:0:1}" == '-' ]] && abort "Unknown arg: $1"

[[ -z "$1" ]] && abort "No image specified."


## Main
echo "Moving $lck to ${lck}-backup..."
[[ -r "$lck" ]] && mv -vf ${lck}{,-backup}

echo "Generating ${lck}..."
LOCK="$(run -i "$plt" "$@")"

[[ -z "$LOCK" ]] && abort "Could not create/get lock file."

echo -e "\nGenerated, writing:"
lll
echo "$LOCK" | tee "$lck"
lll

[[ -n "$NOCHECK" ]] && exit 0

## Verify
# We can't remove the platform with existing lock, Error:
# > Unable to remove the platform `x86_64-linux` since the only platforms are ruby
echo "Checking validity ${lck}..."
LOCK2="$(run "$@")"

[[ "$LOCK2" == "$LOCK" ]] || {
  lll
  echo "$LOCK2"

  diff -U 0 <(echo "$LOCK") <(echo "$LOCK2")

  abort "Failed. Different Gemfile.lock (see above)."
}

echo "OK"

./test_ubi.sh 2>&1 | tee "test_ubi_$(basename "$(dirname)")-`date -I`.log"
