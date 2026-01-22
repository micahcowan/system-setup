#!/bin/sh

set -e -u -C

srcdir=$(dirname "$0")

main() {
    assert_recursive_checkout

    # 1. Run each module's ./reconcile.sh script, to handle "special
    # cases"
    for m in "$srcdir"/modules/*/reconcile.sh; do
        if contains \* "$m"; then
            echo >&2 "$0: No reconciliation to be done"
            exit 1
        fi

        bname=${m%/reconcile.sh}
        bname=${bname##*/}

        echo
        tput bold >&2
        printf '### Reconciling %s\n' "$bname" >&2
        tput sgr0 >&2

        "$m" # Run the reconcile.sh script
    done

    # 2. Run each module's ./reconcile.sh script with the --list
    # option, to obtain lists of source/destination files to reconcile
    echo
    tput bold >&2
    printf '### Reconciling all changed files\n'
    tput sgr0 >&2

    paths=''
    for m in "$srcdir"/modules/*/reconcile.sh; do
        gather_module_file_lists "$m"
    done

    handle_missing_files
    reconcile_changes

    echo
    tput bold >&2
    printf '### Reconciliation finished\n'
    tput sgr0 >&2
}

contains() {
    test "x${2##*"$1"}" != "x$2"
}

assert_recursive_checkout() {
    if ! test -e "$srcdir"/home-setup/ext/opt-pather/opt-path-setup.sh; then
        echo >&2 'ERROR: git checkout wasn'\''t recursive!'
        echo >&2 'ERROR: run: git submodule update --init --recursive'
        exit 2
    fi
}

gather_module_file_lists() {
    script=$1; shift
    paths=${paths}${paths:+:}$("$script" --list | tr '\n' :)
    paths=${paths%:}
}

paths_add() {
    varname=$1; shift
    eval "${varname}=\"\${${varname}}\${${varname}:+:}\$*\""
}

handle_missing_files() {
    feeder=${paths}
    record=''

    # First, identify the missing files
    missing=
    not_missing=
    while shift_one_path_record feeder record; do
        eval "set -- $record"
        if test -e "$2"; then
            # exists
            paths_add not_missing "$@"
        else
            if test -z "$missing"; then
                printf '%s\n' \
                    "The following files are not present on your system:"
            fi
            paths_add missing "$@"
            printf '  %s\n' "${2}"
        fi
    done

    if test -n "$missing"; then
        missing_copy=$missing
        printf '%s' "Install (Yes/No/Itemize)? "
        read answer
        case "$answer" in
            [Yy]*|[Ii]*)
                while shift_one_path_record missing_copy record; do
                    eval "set -- $record"
                    do_it=
                    case "$answer" in
                        [Ii]*)
                            printf 'copy %s (y/n)? ' "$2"
                            read ans2
                            case "$ans2" in
                                [Yy]*)
                                    do_it=yes
                                    ;;
                            esac
                            ;;
                        *)
                            do_it=yes
                            ;;
                    esac
                    if test -n "$do_it"; then
                        dir=${2%/}  # optional trailing /
                        dir=${dir%/*} # strip final path component
                        mkdir -p "$dir"
                        cp -vr "$1" "$dir"/
                        if test "x$2" != "x${2#$HOME/.rc-available/}"; then
                            # enable new rc files by default
                            name=${2#$HOME/.rc-available/}
                            ln -s ../.rc-available/"$name" ~/.rc-enabled/"$name"
                        fi
                    fi
                done
                ;;
            *)
                printf '%s\n\n' 'Doing nothing with missing files.'
                ;;
        esac
    fi
}

reconcile_changes() {
    # Depends on "missing" and "not_missing" list variable, set up in
    # handle_missing_files()

    # First, find differing files
    differing=''
    not_differing=''
    while shift_one_path_record not_missing record; do
        eval "set -- $record"
        if test "${1%/}" != "${1}" || \
                cmp -s "$1" "$2" >/dev/null 2>/dev/null; then
            paths_add not_differing "$@"
        else
            paths_add differing "$@"
        fi
    done

    if test -n "$not_differing"; then
        printf '%s\n' "The following files are unchanged on the system:"
        while shift_one_path_record not_differing record; do
            eval "set -- $record"
            printf '  %s\n' "$2"
        done
    fi

    if test -n "$differing"; then
        differing_copy=$differing
        printf '%s\n' "The following files are CHANGED on the system:"
        while shift_one_path_record differing_copy record; do
            eval "set -- $record"
            printf '  %s\n' "$2"
        done
        printf '%s\n' "Press ENTER to reconcile"
        read answer

        # Reconcile!
        while shift_one_path_record differing record; do
            eval "set -- $record"
            printf '+vimdiff %s %s\n' "$1" "$2"
            vimdiff "$1" "$2"
        done
    fi
}

shift_one_path_record() {
    varname=$1; shift
    onename=$1; shift
    if eval test -z "\"\$$varname\""; then
        return 1
    fi

    eval "remain=\${${varname}#*:}"
    eval "${onename}=\${${varname}%:\"\$remain\"}"
    if eval test 'x"$remain"' = "x\"\$${varname}\""; then
        remain=''
    fi
    eval "${varname}=\$remain"
    return 0
}

main "$@"
exit 0
