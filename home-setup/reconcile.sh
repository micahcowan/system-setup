#!/bin/sh

set -e -u -C

# paths of files we manage, together with paths where we might
# expect to find them for comparison purposes. Each record is
# separated by :, paths in a record separated by spaces (with the first
# field being "our" path
paths=

main() {
    convert_profile_d

    paths_for_dotfiles
    paths_for_available
    paths_for_ext

    handle_missing_files
    reconcile_changes
}

convert_profile_d() {
    if test -d ~/.profile.d -a ! -d ~/.rc-available; then
        echo 'No ~/.rc-available found. Running install...'
        NO_INSTALL_DOTFILES=yes ./install.sh
        echo
        echo
        echo 'Converting ~/.profile.d files to ~/.rc-available...'

        # Copy all ~/.profile.d files to ~/.rc-available, except a few that
        # changed significantly in the ~/.rc-available scheme and whose
        # functionality will therefore be replaced. And enable them by default.
        for script in ~/.profile.d/*; do
            name=${script##*/}
            case name in
                00path-fns|path-setup)
                    printf 'Skipping %s\n' "$script"
                    name=''
                    ;;
                03ksh)
                    name=ksh
                    ;;
            esac
            if test -n "$name"; then
                cp -v -f "$script" ~/.rc-available/"$name"
                # ...and enable by default
                ln -v -s -f ../.rc-available/"$name" ~/.rc-enabled/"$name"
            fi
        done

        mv -v ~/.profile.d.sh ~/.profile.d.sh.mv.$RANDOM
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
    for file in rc-scripts/*; do
        name=${file##*/}
        dest="$HOME/.rc-available/${name}"
        paths_add paths "$file" "$dest"
    done
}

paths_for_ext() {
    paths_add paths ext/opt-pather/opt-path-setup.sh ~/.rc-available/opt-path-setup.sh
    paths_add paths ext/promptjobs/prompt-jobs.sh ~/.rc-available/prompt-jobs.sh
    paths_add paths ext/profile-loader/dot.runrc.sh ~/.bashrc
    paths_add paths ext/profile-loader/dot.runrc.sh ~/.kshrc
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
