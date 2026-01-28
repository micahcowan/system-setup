#!/bin/sh

set -e -u -C

main() {
    srcdir=$(dirname "$0")

    if test "${1-__nothing__}" = --list; then
        printf '%s %s\n' "$srcdir"/ext/vim-pathogen/autoload/pathogen.vim \
            ~/.vim/autoload/pathogen.vim
        printf '%s %s\n' "$srcdir"/ext/vim-asm_ca65/ \
            ~/.vim/bundle/vim-asm_ca65/
    else
        # Currently tests everything before attempting install, so safe
        "$srcdir"/install.sh
    fi
}

main "$@"
exit 0
