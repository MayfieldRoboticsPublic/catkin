#!/bin/sh

set -eu

DEB_VERSION="0.6.19-0may1"
TMPDIR=$(mktemp -d)

trap 'cleanup' EXIT

cleanup()
{
    rm -rf $TMPDIR
}

usage()
{
    echo "usage: $(basename $0) SOURCE_PATH"
}

fpm_cmd()
{
    fpm \
        --input-type dir \
        --output-type deb \
        --architecture native \
        --version "${DEB_VERSION}" \
        --maintainer "Paul Mathieu <paul@mayfieldrobotics.com>" \
        "$@"
}

main()
{
    if [ $# != 1 ]; then
        usage
        exit 1
    fi

    local path=$(readlink -f $1)
    local oldpwd=$PWD

    cd $TMPDIR
    cmake -DCMAKE_INSTALL_PREFIX=/opt/ros/indigo $path
    make -j4
    make install DESTDIR=$PWD/install

    fpm_cmd \
        -n ros-indigo-catkin \
        --description "The catkin build system" \
        -C install \
        opt/

    mv *.deb $oldpwd/
}

main "$@"
