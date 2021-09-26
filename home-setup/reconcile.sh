#!/bin/sh

set -e -u -C

have_rc_d=
have_profile_d=
have_dotfiles=

# paths of files we manage, together with paths where we might
# expect to find them for comparison purposes. Each record is
# separated by :, paths in a record separated by spaces (with the first
# field being "our" path
paths=

main() {
    determine_rc_or_profile_d

    paths_for_dotfiles
    paths_for_available
    paths_for_ext

    handle_missing_files
    reconcile_changes
}

determine_rc_or_profile_d() {
    # Are the rc files stored in ~/.rc-available, or in
    # ~/.profile.d (old style)?
    if test -d ~/.rc-available; then
        have_rc_d=yes
    fi
    if test -d ~/.profile.d; then
        have_profile_d=yes
    fi
    if test -n "$have_rc_d" -o -n "$have_profile_d"; then
        have_dotfiles=yes
    fi
}

paths_for_dotfiles() {
    for file in $(cd dot-files && find . -type f); do
        file=${file#./}
        paths_add paths dot-files/"$file" ~/"$file"
    done
}

paths_add() {
    varname=$1; shift
    eval "${varname}=\"\${${varname}}\${${varname}:+:}\$*\""
}

paths_for_available() {
    : # XXX
}

paths_for_ext() {
    : # XXX
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
                        mkdir -p "${2%/*}"
                        cp -v "$1" "$2"
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
        if cmp -s "$1" "$2" >/dev/null 2>/dev/null; then
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
