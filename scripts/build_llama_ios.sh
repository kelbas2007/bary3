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
cmake --build . --config Release -j$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

# Создаем framework
echo "Creating framework..."
cd ..
FRAMEWORK_DIR="ios/Frameworks/llama.framework"
mkdir -p "$FRAMEWORK_DIR"

# Ищем скомпилированную библиотеку
if [ -f "$BUILD_DIR/libllama.dylib" ]; then
    cp "$BUILD_DIR/libllama.dylib" "$FRAMEWORK_DIR/llama"
    echo "✅ Framework created at $FRAMEWORK_DIR"
elif [ -f "$BUILD_DIR/Release/libllama.dylib" ]; then
    cp "$BUILD_DIR/Release/libllama.dylib" "$FRAMEWORK_DIR/llama"
    echo "✅ Framework created at $FRAMEWORK_DIR"
else
    echo "WARNING: libllama.dylib not found in expected locations"
    echo "Searching for .dylib files..."
    find "$BUILD_DIR" -name "*.dylib" -type f
    exit 1
fi

echo ""
echo "=== Build complete ==="
echo "Framework is in: $FRAMEWORK_DIR"
