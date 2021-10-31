#!/bin/sh

set -e -u -C

srcdir=$(dirname "$0")

if test ! -e ~/.vim/autoload/pathogen.vim; then
    mkdir -p ~/.vim/autoload
    cp -v "$srcdir"/ext/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload
fi

if test ! -d ~/.vim/bundle/vim-asm_ca65; then
    mkdir -p ~/.vim/bundle
    cp -a -v "$srcdir"/ext/vim-asm_ca65 ~/vim/bundle/
fi

exit 0
