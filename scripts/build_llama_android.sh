#!/bin/bash
# Скрипт для компиляции llama.cpp для Android
# 
# Требования:
# - Android NDK (установлен и настроен)
# - CMake 3.18+
# - Git

set -e

echo "=== Building llama.cpp for Android ==="

# Настройки
LLAMA_CPP_DIR="llama.cpp"
BUILD_DIR="build-android"
NDK_PATH="${ANDROID_NDK_HOME:-$ANDROID_NDK_ROOT}"

if [ -z "$NDK_PATH" ]; then
    echo "ERROR: ANDROID_NDK_HOME or ANDROID_NDK_ROOT not set"
    echo "Please set one of these environment variables to your NDK path"
    exit 1
fi

echo "NDK Path: $NDK_PATH"

# Проверяем наличие NDK
if [ ! -d "$NDK_PATH" ]; then
    echo "ERROR: NDK directory does not exist: $NDK_PATH"
    exit 1
fi

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

# Собираем только для arm64-v8a (основная архитектура для Android)
ARCH="arm64-v8a"
ANDROID_ABI="arm64-v8a"

echo ""
echo "=== Building for $ARCH ==="

# Конфигурируем CMake
cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM=android-23 \
    -DANDROID_STL=c++_shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DGGML_METAL=OFF \
    -DGGML_CUDA=OFF \
    -DGGML_OPENBLAS=OFF \
    -DGGML_BLAS=OFF

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

# Собираем
echo "Building..."
cmake --build . --config Release -j$(nproc)

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

# Копируем библиотеку в нужное место
OUTPUT_DIR="../../android/app/src/main/jniLibs/$ANDROID_ABI"
mkdir -p "$OUTPUT_DIR"

# Ищем скомпилированную библиотеку
if [ -f "libllama.so" ]; then
    cp libllama.so "$OUTPUT_DIR/"
    echo "✅ Copied libllama.so to $OUTPUT_DIR"
elif [ -f "build/libllama.so" ]; then
    cp build/libllama.so "$OUTPUT_DIR/"
    echo "✅ Copied libllama.so to $OUTPUT_DIR"
else
    echo "WARNING: libllama.so not found in build directory"
    echo "Searching for .so files..."
    find . -name "*.so" -type f
    exit 1
fi

echo ""
echo "=== Build complete ==="
echo "Libraries are in: android/app/src/main/jniLibs/"
