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
# Сначала пробуем собрать статическую библиотеку (по умолчанию)
# Затем попробуем создать framework из статической, если нужно
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
FOUND_LIB=""

# Проверяем возможные расположения
POSSIBLE_PATHS=(
    "$BUILD_DIR/libllama.dylib"
    "$BUILD_DIR/Release/libllama.dylib"
    "$BUILD_DIR/lib/llama.dylib"
    "$BUILD_DIR/lib/libllama.dylib"
    "$BUILD_DIR/libllama.a"
    "$BUILD_DIR/Release/libllama.a"
    "$BUILD_DIR/lib/llama.a"
    "$BUILD_DIR/lib/libllama.a"
)

echo "Searching for compiled library..."
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        echo "Found library at: $path"
        FOUND_LIB="$path"
        LIB_FOUND=true
        break
    fi
done

# Если не нашли, ищем рекурсивно
if [ "$LIB_FOUND" = false ]; then
    echo "WARNING: Library not found in expected locations"
    echo "Searching recursively..."
    FOUND_LIB=$(find "$BUILD_DIR" -name "*llama*.dylib" -o -name "*llama*.a" 2>/dev/null | head -1)
    if [ -n "$FOUND_LIB" ]; then
        echo "Found library at: $FOUND_LIB"
        LIB_FOUND=true
    fi
fi

if [ "$LIB_FOUND" = false ]; then
    echo "ERROR: Could not find compiled library"
    echo "Build directory contents:"
    ls -la "$BUILD_DIR" | head -20
    echo ""
    echo "Searching for all library files:"
    find "$BUILD_DIR" -name "*.dylib" -o -name "*.a" 2>/dev/null | head -10
    exit 1
fi

# Копируем библиотеку в framework
if [[ "$FOUND_LIB" == *.dylib ]]; then
    # Shared library - просто копируем
    cp "$FOUND_LIB" "$FRAMEWORK_DIR/llama"
    echo "✅ Copied dylib to framework"
elif [[ "$FOUND_LIB" == *.a ]]; then
    # Статическая библиотека - создаем shared из неё
    echo "Found static library, creating shared library from it..."
    
    # Получаем путь к компилятору
    CLANGXX=$(xcrun --find clang++ 2>/dev/null || echo "clang++")
    
    if [ -n "$CLANGXX" ]; then
        echo "Creating shared library from static using $CLANGXX..."
        "$CLANGXX" \
            -shared \
            -o "$FRAMEWORK_DIR/llama" \
            -Wl,-all_load "$FOUND_LIB" \
            -Wl,-noall_load \
            -framework Foundation \
            -framework Metal \
            -framework Accelerate \
            -install_name "@rpath/llama.framework/llama" \
            -compatibility_version 1.0.0 \
            -current_version 1.0.0
        
        if [ -f "$FRAMEWORK_DIR/llama" ]; then
            echo "✅ Created shared library from static library"
        else
            echo "WARNING: Failed to create shared library, copying static library as fallback"
            cp "$FOUND_LIB" "$FRAMEWORK_DIR/llama"
        fi
    else
        echo "WARNING: Could not find clang++, copying static library as fallback"
        cp "$FOUND_LIB" "$FRAMEWORK_DIR/llama"
    fi
fi

# Создаем Info.plist для framework (опционально, но рекомендуется)
cat > "$FRAMEWORK_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>llama</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.llama</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF

echo "✅ Framework created at $FRAMEWORK_DIR"

echo ""
echo "=== Build complete ==="
echo "Framework is in: $FRAMEWORK_DIR"
