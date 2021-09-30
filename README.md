# system-setup

## Summary

Over many years of being a Unix (and particularly Debian/Ubuntu) user, I've amassed a number of configuration files and shell bootup scripts that I have come to rely on. Every time I create a user account on a new system, I need to ensure I copy the relevant scripts and configs to the new system - and then if I make changes to these files on one system, I have to remember to sync those changes around to my other systems!

This project provides an **install.sh** script intended too be run once, and it will perform as much of this bootstrapping process as possible, instantly providing me with a "usable system" (by my standards). It also contains a **reconcile.sh** script that detects when changes have been made to these files on a local machine, and seeks to ensure that these changes are synced to the repository - and that any new changes in the repository also get synced down to the system. But provisions are also made to allow me to modify my user environment in such a way that it isn't considered a "deviation" on the standard files, so that genuinely local changes can be preserved.

As these config files and shell scripts are tailored specifically to the author's use, this project consists largely of things that would be of little to no value to someone else (apart from satisfying cases of morbid curiosity).

That being said, it *does* have some components that I think would be of general usefulness to others. I've split these out as submodules/separate git repositories, so that others might pick and choose whichever of these they find useful for adapting into their own comfortable user environments.

These are:
Submodule | Description
--- | ---
[opt-pather](https://github.com/micahcowan/opt-pather/) | allows users to install software under ~/opt, eliminating the need to be root when running (e.g.) `make install`
[profile-loader](https://github.com/micahcowan/profile-loader/) | simple shell script that loads every script in `~/.rc-enabled/*`
[promptjobs](https://github.com/micahcowan/promptjobs/) | generates a prompt that displays a terse, colored summary of suspended programs

## Package management
In addition to installing configuration and shell files, a script is run to install a minimal set of Debian packages that I want in every (or nearly every) environment I'm in. That script assumes we're running on an apt-based system, with **sudo** privileges, which may not always be the case.
