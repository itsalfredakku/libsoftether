#!/bin/sh

# Exit on error
set -e

# Check if git is installed
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

# Check if patch is installed
git submodule update --init --recursive

# Build the project
mkdir -p build

# Set environment variables
export PROJECT_ROOT="$(pwd)"
export OPEN_SSL_ROOT="$PROJECT_ROOT/openssl"
export SE_VPN_ROOT="$PROJECT_ROOT/SoftEtherVPN"
export IOS_CMAKE_ROOT="$PROJECT_ROOT/ios-cmake"
export NCURSES_ROOT="$PROJECT_ROOT/ncurses"

# Compiler and SDK paths for cross-compilation
export CC="clang -isysroot $(xcrun --sdk iphoneos --show-sdk-path)"
export CROSS_TOP="$(xcrun --sdk iphoneos --show-sdk-platform-path)/Developer"
export CROSS_SDK="$(xcrun --sdk iphoneos --show-sdk-path | xargs basename)"
export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
export CFLAGS="-DTARGET_OS_IPHONE"
export IPHONEOS_DEPLOYMENT_TARGET="13.0"

# Build OpenSSL
if [ -d "$OPEN_SSL_ROOT" ]; then
    cd "$OPEN_SSL_ROOT"
    echo '===================================='
    echo 'Configuring OpenSSL...'
    echo '===================================='
    ./Configure ios64-cross no-shared || { echo 'OpenSSL configuration failed'; exit 1; }
    make || { echo 'Failed to build OpenSSL'; exit 1; }
    echo 'Finished building OpenSSL'
    echo '===================================='
    cd "$PROJECT_ROOT"
fi

# Build ncurses
if [ -d "$NCURSES_ROOT" ]; then
    # cd "$NCURSES_ROOT"
    # if grep -Fq 'defined(__APPLE__) && !defined(TARGET_OS_IPHONE) && !TARGET_OS_IPHONE' "$NCURSES_ROOT/ncurses/tinfo/lib_baudrate.c"; then
    #   echo "Patch already applied. Skipping."
    # # else
    #   # Apply the patch
    #   # echo 'Applying patch to Ncurses...'
    #   # echo 'Type the following value on prompt: ncurses/ncurses/tinfo/lib_baudrate.c'
    #   # patch -p1 < "$PROJECT_ROOT/patch/lib_baudrate.c.diff" || { echo 'Failed to apply patch to Ncurses'; exit 1; }
    #   # send this value on prompt 'ncurses/tinfo/lib_baudrate.c'
    #   # no interractive prompt during patching
    # fi
    cd "$NCURSES_ROOT"
    echo '===================================='
    echo 'Configuring Ncurses...'
    echo '===================================='
    ./configure --host=arm-apple-darwin --without-shared --without-progs --without-tests --enable-widec --with-build-cc || { echo 'Ncurses configuration failed'; exit 1; }
    make || { echo 'Failed to build Ncurses'; exit 1; }
    echo 'Finished building Ncurses'
    echo '===================================='
    cd "$PROJECT_ROOT"
fi

# Build SoftEtherVPN
if [ -d "$SE_VPN_ROOT" ]; then
    cd "$SE_VPN_ROOT"
    echo '===================================='
    echo 'Configuring SoftEtherVPN...'
    echo '===================================='
    ./configure
    make -C build
    # make -C build install # Not needed
    echo 'Finished building SoftEtherVPN'
    echo '===================================='
    cd "$PROJECT_ROOT"
fi
