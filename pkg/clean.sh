#!/bin/bash
#
# Clean up files created by performing package builds.
#
function cleanup_deb {
    base=$1
    rm -rf $base\-*
    rm -f $base\_*.orig.tar.gz
    rm -f $base\_*_all.deb
    rm -f $base\_*.diff.gz
    rm -f $base\_*.dsc
    rm -f $base\_*.build
    rm -f $base\_*.buildinfo
    rm -f $base\_*.changes
}
cleanup_deb n2-dbd-sqllite

if [ -d ../deploy ]; then
    rm -rf ../deploy
fi
if [ -d rpms ]; then
    rm -r rpms
fi
