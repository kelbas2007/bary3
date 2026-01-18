#!/bin/bash
# Скрипт для компиляции llama.cpp для iOS
# 
# Требования:
# - Xcode Command Line Tools
# - CMake 3.18+
# - Git

set -e

echo "=== Building llama.cpp for iOS ==="

# Настройки
LLAMA_CPP_DIR="llama.cpp"
BUILD_DIR="build-ios"

# Клонируем llama.cpp если еще не клонирован
if [ ! -d "$LLAMA_CPP_DIR" ]; then
    echo "Cloning llama.cpp repository..."
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    git submodule update --init --recursive
    cd ..
fi

# Создаем директорию для сборки
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Настройка CMake для iOS
echo "Configuring CMake for iOS..."

# Получаем путь к iOS SDK
IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || echo "")
IOS_SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || echo "17.0")

if [ -z "$IOS_SDK_PATH" ]; then
    echo "WARNING: Could not get iOS SDK path, using defaults"
    IOS_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
fi

echo "iOS SDK Path: $IOS_SDK_PATH"
echo "iOS SDK Version: $IOS_SDK_VERSION"

# Конфигурируем CMake
# ВАЖНО: llama.cpp использует LLAMA_BUILD_SHARED_LIBS, а не BUILD_SHARED_LIBS
cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_VERSION="$IOS_SDK_VERSION" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_SYSROOT="$IOS_SDK_PATH" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_SHARED_LIBS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DGGML_METAL=ON \
    -DGGML_USE_ACCELERATE=ON \
    -DGGML_CUDA=OFF \
    -DGGML_OPENBLAS=OFF \
    -DGGML_BLAS=OFF

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

# Компиляция
echo "Building llama.cpp..."
CPU_COUNT=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)
echo "Using $CPU_COUNT parallel jobs"
cmake --build . --config Release -j$CPU_COUNT || cmake --build . -j$CPU_COUNT

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    echo "Build directory contents:"
    ls -la
    exit 1
fi

echo "Build completed. Checking for output files..."
ls -la lib* 2>/dev/null || echo "No lib* files in current directory"

# Создаем framework
echo "Creating framework..."
cd ..
FRAMEWORK_DIR="ios/Frameworks/llama.framework"
mkdir -p "$FRAMEWORK_DIR"

# Ищем скомпилированную библиотеку
LIB_FOUND=false

if [ -f "$BUILD_DIR/libllama.dylib" ]; then
    cp "$BUILD_DIR/libllama.dylib" "$FRAMEWORK_DIR/llama"
    LIB_FOUND=true
elif [ -f "$BUILD_DIR/Release/libllama.dylib" ]; then
    cp "$BUILD_DIR/Release/libllama.dylib" "$FRAMEWORK_DIR/llama"
    LIB_FOUND=true
elif [ -f "$BUILD_DIR/libllama.a" ]; then
    # Статическая библиотека - создаем framework из .a
    cp "$BUILD_DIR/libllama.a" "$FRAMEWORK_DIR/llama"
    LIB_FOUND=true
elif [ -f "$BUILD_DIR/Release/libllama.a" ]; then
    cp "$BUILD_DIR/Release/libllama.a" "$FRAMEWORK_DIR/llama"
    LIB_FOUND=true
fi

if [ "$LIB_FOUND" = false ]; then
    echo "WARNING: libllama.dylib or libllama.a not found in expected locations"
    echo "Searching for library files..."
    find "$BUILD_DIR" -name "*.dylib" -o -name "*.a" | head -5
    echo ""
    echo "Listing build directory contents:"
    ls -la "$BUILD_DIR" | head -10
    exit 1
fi

echo "✅ Framework created at $FRAMEWORK_DIR"

echo ""
echo "=== Build complete ==="
echo "Framework is in: $FRAMEWORK_DIR"
