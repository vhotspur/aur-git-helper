# AUR Git Helper

This script assumes that you have all packages installed from AUR cloned
into `packages` subdirectory in this repository.

The script `find-updates.sh` does a pull for all your packages to check for
newer versions and compares them with currently installed ones.
To standard error, summary is printed, standard output contains also copy of
the individual `PKGBUILD`s, so you can check them all at once.

The script `build-packages.sh` builds packages given to it on standard input.
At the end, it prints `pacman` command for mass installation.

Typical usage looks like this:

    # See on screen overview of what should be installed
    ./find-updates.sh >updates.txt
    
    # Check PKGBUILDs and INSTALL files for issues,
    # remove packages you do not want to install
    vim updates.txt
    
    # Build the packages
    ./build-packages.sh <updates.txt
    
    # Copy the last line from the output to install the packages
    pacman -U ...
    
Report problems through GitHub issues or e-mail me directly.
