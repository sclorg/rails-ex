#!/usr/bin/bash

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

# Let's try removing x86_64 platform from lock
plt='bundle lock --add-platform ruby; bundle lock --remove-platform x86_64-linux'

# Test script can actually be used for lock generation as well
tst="$(readlink -e "$(dirname "$0")/test_cont.sh")"
[[ -x "$tst" ]] || abort "Could not find or run 'test_cont.sh', path: $tst"


## Args
[[ "$1" == '-d' ]] && {
  DEBUG="$1"
  shift
  :
} || DEBUG=

[[ "$1" == '-n' ]] && {
  NOCHECK="$1"
  shift
  :
} || NOCHECK=

[[ -z "$1" ]] && abort "Error: No image specified."


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
