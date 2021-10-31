#!/bin/sh

set -e -u -C

srcdir=$(dirname "$0")

contains() {
    test "x${2##*"$1"}" != "x$2"
}

if ! test -t 2; then
    tput() { :; }
    finish() { :; }
else
    finish() { printf \\a; sleep 1; printf \\a; }
fi

if ! test -e "$srcdir"/home-setup/ext/opt-pather/opt-path-setup.sh; then
    echo >&2 'ERROR: git checkout wasn'\''t recursive!'
    echo >&2 'ERROR: run: git submodule update --init --recursive'
    exit 2
fi

for m in "$srcdir"/modules/*; do
    if contains \* "$m"; then
        echo >&2 "$0: No modules to install!"
        exit 1
    fi

    (
        cd -P "$m"     # chdir to the module directory, resolving symlinks

        echo
        tput bold >&2
        printf '### ' >&2
        if test -f ./description.txt; then
            cat ./description.txt >&2
        else
            basename "$PWD" >&2
        fi
        tput sgr0 >&2
        echo

        ./install.sh
    )
done

echo
tput bold >&2
printf '### Installation finished!\n'
tput sgr0 >&2

finish
