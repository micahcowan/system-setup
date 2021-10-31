#!/bin/sh

set -e -u -C

srcdir=$(dirname "$0")

contains() {
    test "x${2##*"$1"}" != "x$2"
}

if ! test -e "$srcdir"/home-setup/ext/opt-pather/opt-path-setup.sh; then
    echo >&2 'ERROR: git checkout wasn'\''t recursive!'
    echo >&2 'ERROR: run: git submodule update --init --recursive'
    exit 2
fi

for m in "$srcdir"/modules/*/reconcile.sh; do
    if contains \* "$m"; then
        echo >&2 "$0: No reconciliation to be done"
        exit 1
    fi

    (
        dir=$(dirname "$m")
        cd -P "$dir"        # chdir to the module directory, resolving symlinks
        bname=${dir##*/}

        echo
        tput bold >&2
        printf '### Reconciling %s\n' "$bname" >&2
        tput sgr0 >&2

        ./reconcile.sh
    )
done

echo
tput bold >&2
printf '### Reconciliation finished\n'
tput sgr0 >&2
