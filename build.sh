#!/bin/bash

set -e

DEBUG=1

PROG=`basename ${BASH_SOURCE[0]}`
PROG_DIR=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)

cd $PROG_DIR

function print_help {
    echo -e "Usage: $PROG [options]"
    echo -e ""
    echo -e "Options:"
    echo -e "  --generator-default"
    echo -e "    Generate system default package."
    echo -e ""
    echo -e "  --generator-stgz"
    echo -e "    Generate self extracting tar gzip package."
    echo -e ""
    echo -e "  --generator-tbz2"
    echo -e "    Generate tar bzip2 package."
    echo -e ""
    echo -e "  --generator-tgz"
    echo -e "    Generate tar gzip package."
    echo -e ""
    echo -e "  --generator-tz"
    echo -e "    Generate tar compress package."
    echo -e ""
    echo -e "  --generator-zip"
    echo -e "    Generate zip package."
    echo -e ""
    echo -e "  -h, --help"
    echo -e "    Displays help message."
    echo -e ""
    echo -e "  -j [jobs], --jobs=[jobs]"
    echo -e "    Specifies the number of jobs (commands) to run simultaneously."
    echo -e ""
    echo -e "  -r, --release"
    echo -e "    Build in release mode."
    echo -e ""
    echo -e "  --shared"
    echo -e "    Build shared library."
    echo -e ""
    echo -e "  --static"
    echo -e "    Build static library."
    echo -e ""
    echo -e "  -v, --verbose"
    echo -e "    Displays verbose message."
    echo -e ""
    echo -e "  --without-example"
    echo -e "    Build without example project."
    echo -e ""
    echo -e "  --without-unittest"
    echo -e "    Build without unittest project."
    echo -e ""
}

function log {
    if [[ -n $DEBUG ]] ; then
        for ARG in "$@"
        do
            echo "$ARG"
        done
    fi
}

#log "Debug mode"

BUILD_DEBUG_MODE=0
BUILD_SHARED_LIBRARY=0
BUILD_STATIC_LIBRARY=0
BUILD_WITHOUT_EXAMPLE=0
BUILD_WITHOUT_UNITTEST=0
#CMAKE_TEMP_DIR="$PROG_DIR/tmp"
CMAKE_TEMP_DIR="tmp"
CPACK_GENERATOR_DEFAULT=0
CPACK_GENERATOR_STGZ=0
CPACK_GENERATOR_TBZ2=0
CPACK_GENERATOR_TGZ=0
CPACK_GENERATOR_TZ=0
CPACK_GENERATOR_ZIP=0
MAKE_JOBS=1
MAKE_VERBOSE=0
PACKAGE_DIR_NAME="tarball"
PACKAGE_DIR="$PROG_DIR/$PACKAGE_DIR_NAME"

if [ $(uname) = 'Linux' ]; then
    MAKE_JOBS=$(grep processor /proc/cpuinfo | wc -l)
elif [ $(uname) = 'Darwin' ]; then
    MAKE_JOBS=$(sysctl -n hw.ncpu)
else
    MAKE_JOBS=2
fi

CMD_GETOPT=`getopt -o hj:rv --long generator-default,generator-stgz,generator-tbz2,generator-tgz,generator-tz,generator-zip,help,jobs:,release,shared,static,verbose,without-example,without-unittest -n 'example.bash' -- "$@"`
eval set -- "$CMD_GETOPT"
while true ; do
    case "$1" in
        --generator-default) CPACK_GENERATOR_DEFAULT=1; shift ;;
        --generator-stgz) CPACK_GENERATOR_STGZ=1; shift ;;
        --generator-tbz2) CPACK_GENERATOR_TBZ2=1; shift ;;
        --generator-tgz) CPACK_GENERATOR_TGZ=1; shift ;;
        --generator-tz) CPACK_GENERATOR_TZ=1; shift ;;
        --generator-zip) CPACK_GENERATOR_ZIP=1; shift ;;
        -h|--help) print_help; exit 1 ;;
        -j|--jobs) MAKE_JOBS=$2 ; shift 2 ;;
        -r|--release) BUILD_DEBUG_MODE=1; shift ;;
        --shared) BUILD_SHARED_LIBRARY=1; shift ;;
        --static) BUILD_STATIC_LIBRARY=1; shift ;;
        -v|--verbose) MAKE_VERBOSE=1; shift ;;
        --without-example) BUILD_WITHOUT_EXAMPLE=1; shift ;;
        --without-unittest) BUILD_WITHOUT_UNITTEST=1; shift ;;
        --) shift; break ;;
        *) echo "Unknown option: $1"; print_help; exit 1 ;;
    esac
done

if [ $# -ne 0 ] ; then
    echo "Invalid arguments: $*"
    exit 1
fi

if [ $BUILD_SHARED_LIBRARY -eq 0 ] && [ $BUILD_STATIC_LIBRARY -eq 0 ] ; then
    BUILD_STATIC_LIBRARY=1 #Default build static library.
fi

function append_cmake_args {
    for ARG in "$@"
    do
        if [[ -n $CMAKE_ARGS ]] ; then
            CMAKE_ARGS="$CMAKE_ARGS $ARG"
        else
            CMAKE_ARGS=$ARG
        fi
    done
}

function append_make_args {
    for ARG in "$@"
    do
        if [[ -n $MAKE_ARGS ]] ; then
            MAKE_ARGS="$MAKE_ARGS $ARG"
        else
            MAKE_ARGS=$ARG
        fi
    done
}

append_cmake_args "../ -DPACKAGE_DIR_NAME=$PACKAGE_DIR_NAME"
if [ $BUILD_DEBUG_MODE -ne 0 ]; then
    append_cmake_args "-DCMAKE_BUILD_TYPE=Release"
else
    append_cmake_args "-DCMAKE_BUILD_TYPE=Debug"
fi
if [ $BUILD_SHARED_LIBRARY -ne 0 ]; then
    append_cmake_args "-DBUILD_SHARED_LIBRARY=TRUE"
else
    append_cmake_args "-DBUILD_SHARED_LIBRARY=FALSE"
fi
if [ $BUILD_STATIC_LIBRARY -ne 0 ]; then
    append_cmake_args "-DBUILD_STATIC_LIBRARY=TRUE"
else
    append_cmake_args "-DBUILD_STATIC_LIBRARY=FALSE"
fi
if [ $BUILD_WITHOUT_EXAMPLE -ne 0 ]; then
    append_cmake_args "-DBUILD_WITHOUT_EXAMPLE=TRUE"
else
    append_cmake_args "-DBUILD_WITHOUT_EXAMPLE=FALSE"
fi
if [ $BUILD_WITHOUT_UNITTEST -ne 0 ]; then
    append_cmake_args "-DBUILD_WITHOUT_UNITTEST=TRUE"
else
    append_cmake_args "-DBUILD_WITHOUT_UNITTEST=FALSE"
fi
if [ $CPACK_GENERATOR_DEFAULT -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_DEFAULT=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_DEFAULT=FALSE"
fi
if [ $CPACK_GENERATOR_STGZ -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_STGZ=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_STGZ=FALSE"
fi
if [ $CPACK_GENERATOR_TBZ2 -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_TBZ2=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_TBZ2=FALSE"
fi
if [ $CPACK_GENERATOR_TGZ -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_TGZ=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_TGZ=FALSE"
fi
if [ $CPACK_GENERATOR_TZ -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_TZ=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_TZ=FALSE"
fi
if [ $CPACK_GENERATOR_ZIP -ne 0 ]; then
    append_cmake_args "-DCPACK_GENERATOR_ZIP=TRUE"
else
    append_cmake_args "-DCPACK_GENERATOR_ZIP=FALSE"
fi

append_make_args "-j$MAKE_JOBS"
if [ $MAKE_VERBOSE -ne 0 ]; then
    append_make_args "VERBOSE=1"
fi

if [ ! -d $CMAKE_TEMP_DIR ]; then
    mkdir -p $CMAKE_TEMP_DIR
    echo "Create dir: $CMAKE_TEMP_DIR.."
fi

cd $CMAKE_TEMP_DIR
pwd

log "cmake $CMAKE_ARGS"
cmake $CMAKE_ARGS

log "make $MAKE_ARGS"
make $MAKE_ARGS

if [ $CPACK_GENERATOR_DEFAULT -ne 0 ] || [ $CPACK_GENERATOR_STGZ -ne 0 ] || [ $CPACK_GENERATOR_TBZ2 -ne 0 ] || [ $CPACK_GENERATOR_TGZ -ne 0 ] || [ $CPACK_GENERATOR_TZ -ne 0 ] || [ $CPACK_GENERATOR_ZIP -ne 0 ] ; then
    if [ -d $PACKAGE_DIR ]; then
        rm -r $PACKAGE_DIR
        echo "Delete dir: $PACKAGE_DIR.."
    fi
    PKG_FILE_NAMES="$PACKAGE_DIR.*"
    if [ -f $PKG_FILE_NAMES ]; then
        rm $PKG_FILE_NAMES
        echo "Delete file: $PKG_FILE_NAMES..."
    fi

    log "make package"
    make package
    cd -
    cd $PACKAGE_DIR_NAME
    rm -f MD5SUMS SHA1SUMS SHA256SUMS SHA512SUMS
    for fname in *
    do
        md5sum $fname >> MD5SUMS
        sha1sum $fname >> SHA1SUMS
        sha256sum $fname >> SHA256SUMS
        sha512sum $fname >> SHA512SUMS
    done
    cd -
    tar -zcvf "$PACKAGE_DIR_NAME.tar.gz" $PACKAGE_DIR_NAME
else
    cd -
fi

log "Build Success."
