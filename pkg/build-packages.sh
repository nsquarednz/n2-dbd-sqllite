#!/bin/bash
#
# Script to create an RPM package from the N2 DBD SQLLite 1.76 source files.
VERSION=$1
RELEASE=$2

set -e

function usage {
    echo " "
    echo "usage: $0 <version> [release]"
    echo " "
    echo "  e.g. $0 1.76.0"
    echo "  Version must be X.Y with optional .Z"
    echo "  Release must be number, default = 1"
    exit 1
}

# Check validity of version numbers.
if [[ -z "$RELEASE" ]]; then RELEASE=1; fi
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || [[ ! $RELEASE =~ ^[0-9]+$ ]]; then
    usage
fi

# Define our base package name. From there we will add some versoning information as required.
N2DBD_SQLLITE_PACKAGE="n2-dbd-sqllite"
DATE=`date -R`
YEAR=`date '+%Y'`
TAR_N2DBD_SQLLITE_PACKAGE=${N2DBD_SQLLITE_PACKAGE}_$VERSION.orig.tar.gz

OUR_DIR=`pwd`
BASEPATH=`dirname "$OUR_DIR"`
BASEDIR=`basename "$BASEPATH"`

SRC_DIR=..
DEPLOY_DIR=../deploy

################################################################################
# Clean up.
echo "# Cleaning up"
./clean.sh

################################################################################
# Create the package distribution setup
rm -rf $DEPLOY_DIR
mkdir $DEPLOY_DIR

# Firstly the base service package.
echo "# Building base package directory to $DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE"
cd "$OUR_DIR"
mkdir $DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE

# Build the source files for the DBD SQLLite module.
echo "# Compiling: N2 DBD SQLLite Module"
cd "$OUR_DIR/$SRC_DIR/"
perl Makefile.PL

# Perform the make task to generate the built files storing them in a structure that can be
# bundled in our Deb and RPM files.
make
make DESTDIR=$OUR_DIR/$DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE/ install

# Whether we build an RPM or a Debian package depends on which build container we are running in.
# Determine the OS release.
if [ -f "/etc/debian_version" ]; then
    # Remove the pod file.
    cd "$OUR_DIR";
    rm $DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE/usr/local/lib/x86_64-linux-gnu/perl/*/perllocal.pod

    # Create debian packaging.
    echo "# Building Debian package"
    DEBIAN_VERSION="deb"`lsb_release -sr`

    # Build the Debian package
    # COPY THE DEBIAN PACKAGE TEMPLATE.
    #
    # Template was originally created with:
    #   cd $PACKAGE-$VERSION
    #   dh_make -e $PACKAGE@nsquared.nz
    #
    # (But has been customized since then)
    #
    echo "Building debian package in $N2DBD_SQLLITE_PACKAGE-$VERSION/debian"
    mkdir -p $N2DBD_SQLLITE_PACKAGE-$VERSION/debian
    find template-n2-dbd-sqllite -maxdepth 1 -type f -exec cp {} $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/ \;

    # MODIFY TEMPLATE DEFAULTS
    perl -pi -e "s/VERSION/$VERSION/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/changelog
    perl -pi -e "s/RELEASE/$RELEASE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/changelog
    perl -pi -e "s/DATE/$DATE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/changelog
    perl -pi -e "s/PACKAGE/$N2DBD_SQLLITE_PACKAGE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/changelog
    perl -pi -e "s/PACKAGE/$N2DBD_SQLLITE_PACKAGE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/control
    perl -pi -e "s/DATE/$DATE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/copyright
    perl -pi -e "s/YEAR/$YEAR/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/copyright
    perl -pi -e "s/PACKAGE/$N2DBD_SQLLITE_PACKAGE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/$N2DBD_SQLLITE_PACKAGE.install
    perl -pi -e "s/PACKAGE/$N2DBD_SQLLITE_PACKAGE/g" $N2DBD_SQLLITE_PACKAGE-$VERSION/debian/postinst

    # BUILD THE SOURCE TARBALLs that debian needs to build its packages.
    TAR_N2DBD_SQLLITE_PACKAGE=${N2DBD_SQLLITE_PACKAGE}_$DEBIAN_VERSION_$VERSION.orig.tar.gz

    tar zcf $TAR_N2DBD_SQLLITE_PACKAGE $DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE \
        --transform "s#deploy/$N2DBD_SQLLITE_PACKAGE#$N2DBD_SQLLITE_PACKAGE-$VERSION#"
    tar -xzf $TAR_N2DBD_SQLLITE_PACKAGE

    # PERFORM THE PACKAGE BUILD
    #
    # Note: RE: Warnings unknown substitution variable ${shlibs:Depends}
    # See: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=566837
    # (Fixed in dpkg version 1.15.6)
    #
    cd $N2DBD_SQLLITE_PACKAGE-$VERSION
    debuild --no-lintian -uc -us
    cd "$OUR_DIR"

fi

if [ -f "/etc/redhat-release" ]; then
    # Create RPM packaging.
    echo "# Building RPM package"

    # Remove the pod file.
    cd "$OUR_DIR";
    rm $DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE/usr/lib64/perl5/perllocal.pod

    VERSION=$VERSION \
    RELEASE=$RELEASE \
    PACKAGE=$N2DBD_SQLLITE_PACKAGE \
        rpmbuild -v \
        --define "_builddir $OUR_DIR/$DEPLOY_DIR/$N2DBD_SQLLITE_PACKAGE" \
        --define "_rpmdir %(pwd)/rpms" \
        --define "_srcrpmdir %(pwd)/rpms" \
        --define "_sourcedir %(pwd)/../" \
        -ba n2-dbd-sqllite.spec
fi
