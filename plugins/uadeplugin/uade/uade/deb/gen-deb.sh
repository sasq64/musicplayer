#!/bin/sh

if test ! -e "configure" ; then
    echo "You must be located in the twin root directory, and then run deb/gen-deb.sh deb/control"
    exit 1
fi

if test -n "$1" ; then
    tool="$1"
    shift 1
else
    tool="uade123"
fi

package="uade-$tool"
depends="uade-uadecore"

if test "$tool" = "uadecore" ; then
    depends=""
elif test "$tool" = "uade123" ; then
    package="uade123"
fi

version=$(cat version)
arch=$(dpkg --print-architecture)
if test -z "$arch" ; then
    echo "Unknown (Debian) architecture. dpkg --print-architecture failed."
    arch="unknown"
fi

sed -e "s|{VERSION}|$version|g" \
    -e "s|{ARCHITECTURE}|$arch|g" \
    -e "s|{PACKAGE}|$package|g" \
    -e "s|{DEPENDS}|$depends|g" \
    < deb/control.in > deb/control

rm -rf rel
mkdir rel

PACKAGEPREFIX="$(pwd)/rel"

./configure --prefix=/usr --package-prefix="$PACKAGEPREFIX" "--only-$tool" "$@"

make install

control="deb/control"
mkdir -p "$PACKAGEPREFIX"/DEBIAN/
install -m 644 "$control" "$PACKAGEPREFIX"/DEBIAN/
chmod -R og+rX "$PACKAGEPREFIX"

VERSION=$(cat "$control" | grep "^Version" | cut -d ' ' -f 2)
ARCH=$(cat "$control" | grep "^Architecture" | cut -d ' ' -f 2)
fakeroot dpkg-deb -b "$PACKAGEPREFIX" "$package"_"$VERSION"_"$ARCH".deb
