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

# Настройки для iOS
IOS_PLATFORM="OS64" # Для arm64 (iPhone/iPad)
SIMULATOR_PLATFORM="SIMULATOR64" # Для x86_64 симулятора

# Получаем путь к iOS SDK
IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
IOS_SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)

echo "iOS SDK Path: $IOS_SDK_PATH"
echo "iOS SDK Version: $IOS_SDK_VERSION"

# Собираем для реальных устройств (arm64)
echo ""
echo "=== Building for iOS Device (arm64) ==="
mkdir -p build-device
cd build-device

cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_VERSION="$IOS_SDK_VERSION" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_SYSROOT="$IOS_SDK_PATH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DGGML_METAL=ON \
    -DGGML_USE_ACCELERATE=ON \
    -DGGML_CUDA=OFF \
    -DGGML_OPENBLAS=OFF

cmake --build . --config Release -j$(sysctl -n hw.ncpu)

cd ..

# Собираем для симулятора (x86_64/arm64)
echo ""
echo "=== Building for iOS Simulator ==="
mkdir -p build-simulator
cd build-simulator

SIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
SIMULATOR_SDK_VERSION=$(xcrun --sdk iphonesimulator --show-sdk-version)

cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_SYSTEM_VERSION="$SIMULATOR_SDK_VERSION" \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DCMAKE_OSX_SYSROOT="$SIMULATOR_SDK_PATH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DGGML_METAL=OFF \
    -DGGML_USE_ACCELERATE=ON \
    -DGGML_CUDA=OFF \
    -DGGML_OPENBLAS=OFF

cmake --build . --config Release -j$(sysctl -n hw.ncpu)

cd ..

# Создаем универсальный framework (fat binary)
echo ""
echo "=== Creating universal framework ==="

FRAMEWORK_DIR="../../ios/Frameworks/llama.framework"
mkdir -p "$FRAMEWORK_DIR"

# Копируем заголовки (если есть)
if [ -d "$LLAMA_CPP_DIR/include" ]; then
    cp -r "$LLAMA_CPP_DIR/include" "$FRAMEWORK_DIR/Headers"
fi

# Создаем универсальную библиотеку
lipo -create \
    build-device/libllama.dylib \
    build-simulator/libllama.dylib \
    -output "$FRAMEWORK_DIR/llama"

echo ""
echo "=== Build complete ==="
echo "Framework is in: ios/Frameworks/llama.framework"
