#!/bin/sh
set -e

# Set environment variables
export PROJECT_ROOT="$(pwd)"
export OPEN_SSL_ROOT="$PROJECT_ROOT/openssl"
export NCURSES_ROOT="$PROJECT_ROOT/ncurses"
export IOS_CMAKE_ROOT="$PROJECT_ROOT/ios-cmake"
export IOS_TOOLCHAIN_FILE="${IOS_CMAKE_ROOT}/ios.toolchain.cmake"
export BUILD_DIR="$PROJECT_ROOT/build/platform/ios/libsoftether/Release/ios"
export CC="clang -isysroot $(xcrun --sdk iphoneos --show-sdk-path)"
export CROSS_TOP="$(xcrun --sdk iphoneos --show-sdk-platform-path)/Developer"
export CROSS_SDK="$(xcrun --sdk iphoneos --show-sdk-path | xargs basename)"
export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"

# Create and navigate to the build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit

# Run CMake with specified toolchain and options
cmake "$PROJECT_ROOT/SoftEtherVPN" -G "Xcode" \
    -DENABLE_BITCODE=0 \
    -DCMAKE_TOOLCHAIN_FILE="$IOS_TOOLCHAIN_FILE" \
    -DPLATFORM="OS64" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DLWS_WITH_LWSWS=0 \
    -DLWS_WITH_MBEDTLS=0 \
    -DLWS_WITHOUT_TESTAPPS=1 \
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR" \
    -DOPENSSL_ROOT_DIR="$OPEN_SSL_ROOT" \
    -DCMAKE_INCLUDE_PATH="$NCURSES_ROOT/include" \
    -DCMAKE_LIBRARY_PATH="$NCURSES_ROOT/lib" \
    -DCMAKE_OSX_SYSROOT="$(xcrun --sdk iphoneos --show-sdk-path)"

#cmake "$PROJECT_ROOT/SoftEtherVPN" -G "Xcode" \
#    -DENABLE_BITCODE=0 \
#    -DCMAKE_TOOLCHAIN_FILE="$IOS_TOOLCHAIN_FILE" \
#    -DPLATFORM="OS64" \
#    -DCMAKE_BUILD_TYPE=Debug \
#    -DLWS_WITH_LWSWS=0 \
#    -DLWS_WITH_MBEDTLS=0 \
#    -DLWS_WITHOUT_TESTAPPS=1 \
#    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR" \
#    -DOPENSSL_ROOT_DIR="$OPEN_SSL_ROOT" \
#    -DCMAKE_INCLUDE_PATH="$NCURSES_ROOT/include" \
#    -DCMAKE_LIBRARY_PATH="$NCURSES_ROOT/lib" \
#    -DCMAKE_OSX_SYSROOT="$(xcrun --sdk iphoneos --show-sdk-path)"

# Build and install
cmake --build . --config Debug --target install
