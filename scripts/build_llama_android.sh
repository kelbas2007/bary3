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
# Пробуем собрать shared библиотеку через LLAMA_BUILD_SHARED_LIBS
# Если не сработает, соберем статическую и создадим shared из неё
cmake ../"$LLAMA_CPP_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM=android-23 \
    -DANDROID_STL=c++_shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_SHARED_LIBS=ON \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
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
# Отключаем set -e временно для обработки ошибок
set +e
cmake --build . --config Release -j$(nproc)
BUILD_RESULT=$?
set -e

if [ $BUILD_RESULT -ne 0 ]; then
    echo "ERROR: Build failed with exit code $BUILD_RESULT"
    echo "Build directory contents:"
    ls -la
    echo ""
    echo "CMakeCache.txt (first 50 lines):"
    head -50 CMakeCache.txt 2>/dev/null || echo "CMakeCache.txt not found"
    echo ""
    echo "Trying to build without --config flag (for non-VS generators)..."
    set +e
    cmake --build . -j$(nproc)
    BUILD_RESULT=$?
    set -e
    if [ $BUILD_RESULT -ne 0 ]; then
        echo "ERROR: Build failed again with exit code $BUILD_RESULT"
        exit 1
    fi
fi

echo "Build completed. Checking for output files..."
ls -la lib* 2>/dev/null || echo "No lib* files in current directory"

# Копируем библиотеку в нужное место
OUTPUT_DIR="$PROJECT_ROOT/android/app/src/main/jniLibs/$ANDROID_ABI"
mkdir -p "$OUTPUT_DIR"

# Ищем скомпилированную библиотеку
# CMake может создавать библиотеку в разных местах в зависимости от конфигурации
LIB_FOUND=false

# Проверяем возможные расположения (включая статические библиотеки)
# CMake может создавать библиотеки в разных местах в зависимости от генератора
POSSIBLE_PATHS=(
    "libllama.so"
    "lib/llama.so"
    "lib/libllama.so"
    "bin/libllama.so"
    "bin/llama.so"
    "Release/libllama.so"
    "Release/bin/libllama.so"
    "lib/Release/libllama.so"
    "build/libllama.so"
    "libllama.a"
    "lib/llama.a"
    "lib/libllama.a"
    "bin/libllama.a"
    "Release/libllama.a"
    "Release/bin/libllama.a"
    "lib/Release/libllama.a"
    "build/libllama.a"
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

# Если не нашли, ищем все библиотеки (и .so, и .a)
if [ "$LIB_FOUND" = false ]; then
    echo "WARNING: libllama.so not found in expected locations"
    echo "Searching for all library files in build directory..."
    echo "--- .so files ---"
    find . -name "*.so" -type f 2>/dev/null | head -10
    echo "--- .a files ---"
    find . -name "*.a" -type f 2>/dev/null | head -10
    
    # Попробуем найти любую библиотеку llama (и .so, и .a)
    FOUND_LIB=$(find . -name "*llama*.so" -o -name "*llama*.a" 2>/dev/null | head -1)
    if [ -n "$FOUND_LIB" ]; then
        echo "Found llama library at: $FOUND_LIB"
        # Если это .a файл, попробуем создать .so из него
        if [[ "$FOUND_LIB" == *.a ]]; then
            echo "Found static library (.a), creating shared library (.so) from it..."
            
            # Получаем путь к компилятору из NDK
            NDK_TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64"
            if [ ! -d "$NDK_TOOLCHAIN" ]; then
                # Пробуем альтернативные пути
                NDK_TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$(uname -m | tr '[:upper:]' '[:lower:]')-$(uname -s | tr '[:upper:]' '[:lower:]')"
            fi
            
            # Ищем clang++ для создания shared библиотеки
            CLANGXX=$(find "$NDK_TOOLCHAIN" -name "clang++" -type f 2>/dev/null | head -1)
            
            if [ -n "$CLANGXX" ] && [ -f "$CLANGXX" ]; then
                echo "Creating shared library from static library using $CLANGXX..."
                "$CLANGXX" \
                    -shared \
                    -o "$OUTPUT_DIR/libllama.so" \
                    -Wl,--whole-archive "$FOUND_LIB" \
                    -Wl,--no-whole-archive \
                    -Wl,-soname,libllama.so \
                    -llog -landroid
                
                if [ -f "$OUTPUT_DIR/libllama.so" ]; then
                    echo "✅ Created shared library from static library"
                    LIB_FOUND=true
                else
                    echo "WARNING: Failed to create shared library, copying static library as fallback"
                    cp "$FOUND_LIB" "$OUTPUT_DIR/libllama.a"
                    echo "✅ Copied static library to $OUTPUT_DIR/libllama.a"
                    echo "NOTE: Static library may not work with FFI. Consider building as shared library."
                    LIB_FOUND=true
                fi
            else
                echo "WARNING: Could not find clang++ in NDK, copying static library as fallback"
                cp "$FOUND_LIB" "$OUTPUT_DIR/libllama.a"
                echo "✅ Copied static library to $OUTPUT_DIR/libllama.a"
                echo "NOTE: Static library may not work with FFI. Consider building as shared library."
                LIB_FOUND=true
            fi
        else
            cp "$FOUND_LIB" "$OUTPUT_DIR/libllama.so"
            echo "✅ Copied to $OUTPUT_DIR/libllama.so"
            LIB_FOUND=true
        fi
        LIB_FOUND=true
    fi
fi

if [ "$LIB_FOUND" = false ]; then
    echo "ERROR: Could not find compiled library"
    echo "Build directory contents:"
    ls -la
    echo ""
    echo "Checking CMakeCache.txt for LLAMA_BUILD_SHARED_LIBS:"
    grep -i "LLAMA_BUILD_SHARED_LIBS" CMakeCache.txt 2>/dev/null || echo "Not found in CMakeCache.txt"
    echo ""
    echo "Checking for any build artifacts:"
    find . -type f -name "*.so" -o -name "*.a" -o -name "*.dylib" 2>/dev/null | head -20
    exit 1
fi

echo ""
echo "=== Build complete ==="
echo "Libraries are in: android/app/src/main/jniLibs/"
