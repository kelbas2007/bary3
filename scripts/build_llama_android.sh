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

# Проверяем наличие toolchain файла
TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake"
if [ ! -f "$TOOLCHAIN_FILE" ]; then
    echo "ERROR: CMake toolchain file not found: $TOOLCHAIN_FILE"
    echo "NDK Path: $NDK_PATH"
    echo "Contents of NDK path:"
    ls -la "$NDK_PATH" | head -20
    exit 1
fi

echo "Using toolchain: $TOOLCHAIN_FILE"

# Конфигурируем CMake
cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
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
    echo "CMake version:"
    cmake --version
    exit 1
fi

# Собираем
echo "Building..."
echo "Using $(nproc) parallel jobs"
cmake --build . --config Release -j$(nproc) || cmake --build . -j$(nproc)

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    echo "Build directory contents:"
    ls -la
    echo ""
    echo "CMakeCache.txt (first 50 lines):"
    head -50 CMakeCache.txt 2>/dev/null || echo "CMakeCache.txt not found"
    exit 1
fi

echo "Build completed. Checking for output files..."
ls -la lib* 2>/dev/null || echo "No lib* files in current directory"

# Копируем библиотеку в нужное место
OUTPUT_DIR="../../android/app/src/main/jniLibs/$ANDROID_ABI"
mkdir -p "$OUTPUT_DIR"

# Ищем скомпилированную библиотеку
# CMake может создавать библиотеку в разных местах в зависимости от конфигурации
LIB_FOUND=false

# Проверяем возможные расположения
POSSIBLE_PATHS=(
    "libllama.so"
    "lib/llama.so"
    "lib/libllama.so"
    "Release/libllama.so"
    "lib/Release/libllama.so"
    "build/libllama.so"
)

echo "Searching for libllama.so..."
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        echo "Found library at: $path"
        cp "$path" "$OUTPUT_DIR/libllama.so"
        echo "✅ Copied libllama.so to $OUTPUT_DIR"
        LIB_FOUND=true
        break
    fi
done

# Если не нашли, ищем все .so файлы
if [ "$LIB_FOUND" = false ]; then
    echo "WARNING: libllama.so not found in expected locations"
    echo "Searching for all .so files in build directory..."
    find . -name "*.so" -type f | head -10
    
    # Попробуем найти любую библиотеку llama
    FOUND_LIB=$(find . -name "*llama*.so" -type f | head -1)
    if [ -n "$FOUND_LIB" ]; then
        echo "Found llama library at: $FOUND_LIB"
        cp "$FOUND_LIB" "$OUTPUT_DIR/libllama.so"
        echo "✅ Copied to $OUTPUT_DIR/libllama.so"
        LIB_FOUND=true
    fi
fi

if [ "$LIB_FOUND" = false ]; then
    echo "ERROR: Could not find compiled library"
    echo "Build directory contents:"
    ls -la
    exit 1
fi

echo ""
echo "=== Build complete ==="
echo "Libraries are in: android/app/src/main/jniLibs/"
