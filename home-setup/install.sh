#!/bin/sh

set -e -u -C

main() {
    src=$(dirname $0)
    dest=${1-$HOME}
    info "Installing to ${dest}..."
    mkdir -p "${dest}"

    if ! test -e "${src}/ext/opt-pather/opt-path-setup.sh"; then
        die "Missing submodules! Run 'git submodule update --init' and try again"
    fi

    if test -z "${NO_INSTALL_DOTFILES-}"; then
        install_dotfiles
    else
        info "(Skipping dotfiles installation - handled in reconciliation?)"
    fi
    populate_available
    populate_enabled
    install_rc

    info "Succeeded!"
    info "Try: exec ${SHELL:-/bin/bash}"
}

alias echo='printf "%s\n"'
test -t 2 || alias tput=:

info() {
    tput bold >&2 2>/dev/null
    echo "$*" >&2
    tput sgr0 >&2 2>/dev/null
}

verb() {
    echo "  $*" >&2
}

die() {
    tput setaf 1 >&2
    tput bold    >&2
    echo "$*"
    tput sgr0    >&2
    exit 1
}

contains() {
    test "x${2%%"$1"*}" != "x${2}"
}

## Safe-install functions ##

take_safe_ownership() {
    set -o noclobber # already set, but be sure anyway
    file=$1
    if > "$file"; then
        return 0
    fi
    file=$file.orig
    if > "$file"; then
        verb "$1 already exists, moving to $file."
        mv -f -- "$1" "$file"
        if ! > "$1"; then
            die "$1 was recreated after moving same-named file, refusing to proceed."
        fi
    else
        nfile=$file."$(date +%Y%m%d)"
        verb "$file also already exists. Trying $nfile."
        file=$nfile
        if ! > "$file"; then
            die "$file ALSO also already exists. Refusing to proceed."
        else
            mv -f -- "$1" "$file"
            if ! > "$1"; then
                die "$1 was recreated after moving same-named file, refusing to proceed."
            fi
        fi
    fi
}

hardlink() {
    verb hardlink "$1" "$2"
    take_safe_ownership "$2"
    ln -f -- "$1" "$2"
}

symlink() {
    verb symlink "$1" "$2"
    take_safe_ownership "$2"
    ln -sf -- "$1" "$2"
}

copy() {
    verb copy "$1" "$2"
    take_safe_ownership "$2"
    cp -f -- "$1" "$2"
}

## Primary tasks ##

install_dotfiles() {
    info "Installing dot-files to ${dest}..."

    ( cd "$src"/dot-files && find . -type f ) | while read -r file; do
        mkdir -p "$dest"/"$(dirname "$file")"
        copy "$src"/dot-files/"$file" "$dest"/"$file"
    done
}

populate_available() {
    avail="${dest}/.rc-available"
    info "Populating scripts in ${avail}..."
    mkdir -p "$avail"

    copy "$src"/ext/opt-pather/opt-path-setup.sh "${avail}/opt-path-setup.sh"
    copy "$src"/ext/promptjobs/prompt-jobs.sh "${avail}/prompt-jobs.sh"

    for file in "$src"/rc-scripts/*; do
        copy "$file" "${avail}/$(basename "$file")"
    done
}

populate_enabled() {
    enabled="${dest}/.rc-enabled"
    info "Populating links in ${enabled}..."
    mkdir -p "$enabled"

    for file in "${avail}"/*; do
        contains .orig "$file" && continue
        bfile=$(basename "$file")
        dfile=$bfile
        case "$dfile" in
            init|opt-path-setup.sh)
                dfile=00-$dfile
                ;;
            *)
                ;;
        esac
        symlink "../.rc-available/$bfile" "${enabled}/$dfile"
    done
}

install_rc() {
    info 'Installing bashrc...'
    copy "$src"/ext/profile-loader/dot.runrc.sh "${dest}/.bashrc"
    copy "$src"/ext/profile-loader/dot.runrc.sh "${dest}/.kshrc"
}

main "$@"
exit 0
