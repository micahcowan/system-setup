#!/bin/sh

set -e -u -C

main() {
    dest=${1-$HOME}
    info "Installing to ${dest}..."
    mkdir -p "${dest}"

    populate_available
    populate_enabled
    install_rc

    info "Succeeded!"
    info "Try: exec $SHELL"
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

endswith() {
    test "x${2%"$1"}" != "x${2}"
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

populate_available() {
    avail="${dest}/.rc-available"
    info "Populating scripts in ${avail}..."
    mkdir -p "$avail"

    copy ext/opt-pather/opt-path-setup.sh "${avail}/opt-path-setup.sh"
    copy ext/promptjobs/prompt-jobs.sh "${avail}/prompt-jobs.sh"

    for file in rc-scripts/*; do
        copy "$file" "${avail}/$(basename "$file")"
    done
}

populate_enabled() {
    enabled="${dest}/.rc-enabled"
    info "Populating links in ${enabled}..."
    mkdir -p "$enabled"

    for file in "${avail}"/*; do
        endswith .orig "$file" && continue
        bfile=$(basename "$file")
        symlink "../.rc-available/$bfile" "${enabled}/$bfile"
    done
}

install_rc() {
    info 'Installing bashrc...'
    copy ext/profile-loader/dot.runrc.sh "${dest}/.bashrc"
    copy ext/profile-loader/dot.runrc.sh "${dest}/.kshrc"
}

main "$@"
exit 0
