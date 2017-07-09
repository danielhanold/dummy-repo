#!/bin/bash

# set version number and description

# Author: engelbert gruber (taken from Lea Wiemann's release.sh)
# Contact: grubert@users.sourceforge.net
# Revision: $Revision$
# Date: $Date$
# Copyright: This script has been placed in the public domain.

# USAGE see: docutils/docs/dev/release.txt

# must be run from docutils trunk/docutils,
# because HISTORY and RELEASE_NOTES.txt are modified.

set -e

echo "Change version identifier"
if [ -z "$1" ] ; then
    echo "USAGE"
    echo "    set_version.sh  <new_version-identifier>"
    echo ""
    echo "Version identifier: major.minor[.micro][<pre>][.dev]"
    echo "    micro is for bug-fix releases and left out if zero"
    echo "    prereleases get '(a|b|rc[N])#' appended"
    echo "    a '.dev' suffix indicates repository versions (no release)"
    echo ""
    echo "Samples"
    echo "    0.14b.dev 0.14b 0.14rc1.dev 0.14rc1 0.14 0.15b.dev"
    exit
fi

old_ver="`python -c 'import docutils; print docutils.__version__'`"
new_ver=$1

echo "from current Docutils version ${old_ver} to ${new_ver}"

function set_ver()
{
    # Parameters: old_version new_version
    shopt -s extglob
    echo Determining list of files to be changed...
    # BUG ls lists directories but does not descend
    # (try ls --recursive)
    files="docutils/__init__.py setup.py `$svn ls test/functional/expected/ | sed 's|^|test/functional/expected/|'`"
    echo "Now I'll change the version number to ${new_ver} in the following files:"
    echo $files
    echo
    echo 'Press enter to proceed (or enter anything to skip)...'
    read
    if [ ! "$REPLY" ]; then
        echo 'Modifying files with ed...'
        old_ver_regex="`echo "$1" | sed 's/\./\\\\./g'`"
        # "ed" returns an error code if there has been no substitution, so
        # we temporarily deactivate exit-on-error.
        set +e
        for F in $files; do
            (echo ",s/$old_ver_regex/${new_ver}/g"; echo 'wq') | ed "$F"
        done
        set -e
    fi
    echo
    echo 'CAUTION: please look at the diffs carefully, for wrongly'
    echo '         replaced embedded numbers.'
#    checkin "set version number to $2" $files
}

set_ver "$old_ver" "$new_ver"
echo "VERIFY: major, minor, micro, releaselevel (candidate,rinal), prerelease number, pre/release or checkout"
python -c 'import docutils; print "__version_info__ =", docutils.__version_info__'
