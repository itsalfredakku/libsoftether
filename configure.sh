#!/bin/sh

# Exit on error
set -e

# Check if git is installed
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

# Install dependencies
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

# Build OpenSSL
if [ -d "$OPEN_SSL_ROOT" ]; then
    cd "$OPEN_SSL_ROOT"
    echo 'Configuring OpenSSL...'
    ./Configure ios64-cross no-shared
    make
    cd "$PROJECT_ROOT"
fi

# Build ncurses
if [ -d "$NCURSES_ROOT" ]; then
    cd "$NCURSES_ROOT"
    echo 'Configuring Ncurses...'
    ./configure --host=arm-apple-darwin --without-shared --without-progs --without-tests --enable-widec || { echo 'Ncurses configuration failed'; exit 1; }
    make || { echo 'Failed to build Ncurses'; exit 1; }
    cd "$PROJECT_ROOT"
fi

# Build SoftEtherVPN
if [ -d "$SE_VPN_ROOT" ]; then
    cd "$SE_VPN_ROOT"
    echo 'Configuring SoftEtherVPN...'
    ./configure
    make -C build
    # make -C build install # Not needed
    cd "$PROJECT_ROOT"
fi
