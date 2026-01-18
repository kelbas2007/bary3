#!/bin/bash
# Автономный скрипт для компиляции llama.cpp для Android
# Работает без предварительного клонирования llama.cpp

set -e

echo "=== Building llama.cpp for Android ==="

# Проверка переменных окружения
if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$ANDROID_NDK_ROOT" ]; then
    echo "ERROR: ANDROID_NDK_HOME or ANDROID_NDK_ROOT not set"
    echo "Please set one of these environment variables"
    exit 1
fi

NDK_PATH="${ANDROID_NDK_HOME:-$ANDROID_NDK_ROOT}"
echo "Using NDK: $NDK_PATH"

# Проверка наличия NDK
if [ ! -d "$NDK_PATH" ]; then
    echo "ERROR: NDK directory does not exist: $NDK_PATH"
    exit 1
fi

# Проверка CMake
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake not found. Please install CMake"
    exit 1
fi

# Проверка Git
if ! command -v git &> /dev/null; then
    echo "ERROR: Git not found. Please install Git"
    exit 1
fi

# Директории
LLAMA_CPP_DIR="llama.cpp"
BUILD_DIR="build-android"
INSTALL_DIR="android/app/src/main/jniLibs"

# Клонируем llama.cpp если еще не клонирован
if [ ! -d "$LLAMA_CPP_DIR" ]; then
    echo "Cloning llama.cpp repository..."
    git clone --depth 1 https://github.com/ggerganov/llama.cpp.git
    cd "$LLAMA_CPP_DIR"
    git submodule update --init --recursive
    cd ..
fi

cd "$LLAMA_CPP_DIR"

# Создаем директорию для сборки
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Настройка CMake для Android
echo "Configuring CMake for Android..."

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-23 \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_SHARED_LIBS=ON \
    -DCMAKE_C_FLAGS="-march=armv8.4a+dotprod" \
    -DCMAKE_CXX_FLAGS="-march=armv8.4a+dotprod"

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

# Компиляция
echo "Building llama.cpp..."
cmake --build . --config Release -j$(nproc)

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

# Копируем библиотеки
echo "Copying libraries..."
cd ../..

mkdir -p "$INSTALL_DIR/arm64-v8a"

# Ищем скомпилированную библиотеку
if [ -f "$LLAMA_CPP_DIR/$BUILD_DIR/libllama.so" ]; then
    cp "$LLAMA_CPP_DIR/$BUILD_DIR/libllama.so" "$INSTALL_DIR/arm64-v8a/"
    echo "✅ Library copied to $INSTALL_DIR/arm64-v8a/libllama.so"
elif [ -f "$LLAMA_CPP_DIR/$BUILD_DIR/Release/libllama.so" ]; then
    cp "$LLAMA_CPP_DIR/$BUILD_DIR/Release/libllama.so" "$INSTALL_DIR/arm64-v8a/"
    echo "✅ Library copied to $INSTALL_DIR/arm64-v8a/libllama.so"
else
    echo "WARNING: libllama.so not found in expected locations"
    echo "Searching for .so files..."
    find "$LLAMA_CPP_DIR/$BUILD_DIR" -name "*.so" -type f
fi

echo ""
echo "=== Build complete ==="
echo "Library should be in: $INSTALL_DIR/arm64-v8a/libllama.so"
