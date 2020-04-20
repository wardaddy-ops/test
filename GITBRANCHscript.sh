#!/bin/sh

# gittask.sh: taskbased git branching utility

# This script requires that git has been installed and properly configured,
# that the remote "master" and "development" branches exist (locally too) 
# and that a network connection to the "origin" repository is established.

set -o errexit

usage()
{
    echo
    echo "Usage:"
    echo "  gittask.sh new feature name_of_feature"
    echo "    - Creates a new branch off from 'development' named"
    echo "      'feature/name_of_feature'."
    echo "  gittask.sh new release name_of_release"
    echo "    - Creates a new branch off from 'development' named"
    echo "      'release/name_of_release'."
    echo "  gittask.sh new hotfix name_of_hotfix"
    echo "    - Creates a new branch off from 'master' named"
    echo "      'hotfix/name_of_hotfix'."
    echo "  gittask.sh done"
    echo "    - Merges current branch into master and/or development"
    echo "      depending on if it's a feature, release or hotfix."
}

delete_branch()
{
    # Infinite loop, only way out (except for Ctrl+C) is to answer yes or no.
    while true; do
        echo "Delete $current branch? "
        read yn
        case $yn in
            [Yy]* ) 
                git branch -d ${current}
                break
                ;;
            [Nn]* )
                echo "Leaving $current branch as it is."
                break
                ;;
            * )
                echo "Error: Please answer (y)es or (n)o."
                ;;
        esac
    done
}

define_tag()
{
    # Don't proceed until both variables have been set.
    while [ -z ${version_number} ] && [ -z ${version_note} ]; do
        echo "Enter version number (major.minor.fix): "
        read version_number
        echo "Enter version number note: "
        read version_note
    done
}

# Confirm that user is in a git repository, abort otherwise.
git status >/dev/null 2>&1 || { echo "Error: You're not in a git repository."; exit 1; }

# If "new", confirm that the required arguments were provided.

# If "done", proceed to determine current branch and by that what to do next.
