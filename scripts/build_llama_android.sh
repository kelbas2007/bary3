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

# Настройки сборки для разных архитектур
ARCHITECTURES=("arm64-v8a" "x86_64")

for ARCH in "${ARCHITECTURES[@]}"; do
    echo ""
    echo "=== Building for $ARCH ==="
    
    ARCH_BUILD_DIR="build-$ARCH"
    mkdir -p "$ARCH_BUILD_DIR"
    cd "$ARCH_BUILD_DIR"
    
    # Определяем ABI для CMake
    case $ARCH in
        "arm64-v8a")
            ANDROID_ABI="arm64-v8a"
            ;;
        "x86_64")
            ANDROID_ABI="x86_64"
            ;;
        *)
            echo "Unknown architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Конфигурируем CMake
    cmake ../"$LLAMA_CPP_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM=android-23 \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DGGML_METAL=OFF \
        -DGGML_CUDA=OFF \
        -DGGML_OPENBLAS=OFF \
        -DGGML_BLAS=OFF
    
    # Собираем
    cmake --build . --config Release -j$(nproc)
    
    # Копируем библиотеку в нужное место
    OUTPUT_DIR="../../android/app/src/main/jniLibs/$ANDROID_ABI"
    mkdir -p "$OUTPUT_DIR"
    
    if [ -f "libllama.so" ]; then
        cp libllama.so "$OUTPUT_DIR/"
        echo "Copied libllama.so to $OUTPUT_DIR"
    else
        echo "WARNING: libllama.so not found in build directory"
    fi
    
    cd ..
done

echo ""
echo "=== Build complete ==="
echo "Libraries are in: android/app/src/main/jniLibs/"
