#!/bin/sh

set -e -u -C

main() {
    srcdir=$(dirname "$0")

    if test "${1-__nothing__}" != --list; then
        convert_profile_d
    else
        paths_for_dotfiles
        paths_for_available
        paths_for_ext
    fi
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
    for file in $(cd "$srcdir"/dot-files && find . -type f); do
        file=${file#./}
        printf '%s %s\n' "$srcdir"/dot-files/"$file" ~/"$file"
    done
    if test -d ~/.config/nvim; then
        for file in $(cd ~/.config/nvim \
                      && find . -type f | sed 's#^\./##'); do
            file=${file#./}
            printf '%s %s\n' "$srcdir"/dot-files/.config/nvim/"$file" \
                ~/.config/nvim/"$file"
        done
    fi
}

paths_for_available() {
    for file in "$srcdir"/rc-scripts/*; do
        name=${file##*/}
        dest="$HOME/.rc-available/${name}"
        printf '%s %s\n' "$file" "$dest"
    done
}

paths_for_ext() {
    printf '%s %s\n' "$srcdir"/ext/opt-pather/opt-path-setup.sh ~/.rc-available/opt-path-setup.sh
    printf '%s %s\n' "$srcdir"/ext/promptjobs/prompt-jobs.sh ~/.rc-available/prompt-jobs.sh
    printf '%s %s\n' "$srcdir"/ext/profile-loader/dot.runrc.sh ~/.bashrc
    printf '%s %s\n' "$srcdir"/ext/profile-loader/dot.runrc.sh ~/.kshrc
}

main "$@"
exit 0
