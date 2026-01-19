# Native Libraries for llama.cpp

This directory should contain libllama.so compiled for the target architecture.

## For Development (Stub Mode)

The FFI binding works in stub mode without the actual library.
This allows development and testing of the integration code.

## For Production

1. Compile llama.cpp using:
   - WSL: bash scripts/build_llama_android.sh
   - Or download pre-compiled from GitHub releases

2. Place libllama.so in the appropriate architecture folder:
   - arm64-v8a/ for ARM64 devices
   - x86_64/ for x86_64 emulators

3. Update FFI types in llama_ffi_binding.dart based on actual function signatures
