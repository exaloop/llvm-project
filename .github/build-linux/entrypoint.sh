#!/bin/sh -l
set -e

WORKSPACE="${1:-/github/workspace}"

ARCHDEFAULT="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
export ARCHDEFAULT
ARCH=${2:-$ARCHDEFAULT}

echo "Workspace: ${WORKSPACE}; arch: ${ARCH}"
cd "$WORKSPACE"

COMMIT="$(git rev-parse --short HEAD)"
export COMMIT

INSTALL_ROOT=/opt
set --
case "$ARCH" in
  windows-x86_64|windows-arm64)
    INSTALL_ROOT=C:/opt
    case "$ARCH" in
      windows-x86_64) TARGET_TRIPLE=x86_64-pc-windows-msvc ;;
      windows-arm64) TARGET_TRIPLE=aarch64-pc-windows-msvc ;;
    esac
    # clang-cl enables OpenMP's MSVC compatibility code. Use lld-link explicitly
    # so Git Bash's /usr/bin/link cannot shadow the Windows linker.
    set -- \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_ROOT/llvm-codon" \
      -DCMAKE_C_COMPILER=clang-cl \
      -DCMAKE_CXX_COMPILER=clang-cl \
      -DCMAKE_LINKER=lld-link \
      -DCMAKE_C_COMPILER_TARGET="$TARGET_TRIPLE" \
      -DCMAKE_CXX_COMPILER_TARGET="$TARGET_TRIPLE" \
      -DCMAKE_ASM_COMPILER_TARGET="$TARGET_TRIPLE" \
      -DLLVM_HOST_TRIPLE="$TARGET_TRIPLE" \
      -DLLVM_DEFAULT_TARGET_TRIPLE="$TARGET_TRIPLE" \
      -DLLVM_EXTERNAL_PROJECT_PASSTHROUGH=CMAKE_LINKER \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_ENABLE_WERROR=OFF \
      -DLLVM_PARALLEL_LINK_JOBS=1 \
      -DOPENMP_ENABLE_LIBOMPTARGET=OFF
    ;;
esac

cmake -S llvm -G Ninja \
  -B llvm/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_ENABLE_ZSTD=OFF \
  -DLLVM_TARGETS_TO_BUILD=all \
  -DLLVM_ENABLE_PROJECTS="clang;openmp" \
  -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
  -DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
  -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_ORC=OFF \
  -DCOMPILER_RT_BUILD_CRT=OFF \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
  "$@"

cmake --build llvm/build

cmake --install llvm/build --prefix="$INSTALL_ROOT/llvm-codon"

touch "$INSTALL_ROOT/llvm-codon/llvm-codon-${COMMIT}-${ARCH}.version"

case "$ARCH" in
  windows-x86_64|windows-arm64)
    ARCHIVE="$(pwd)/llvm-${ARCH}.zip"
    (
      cd "$INSTALL_ROOT"
      cmake -E tar cf "$ARCHIVE" --format=zip llvm-codon/
    )
    ;;
  *)
    ARCHIVE="llvm-${ARCH}.tar.bz2"
    tar cjvf "$ARCHIVE" -C "$INSTALL_ROOT" llvm-codon/
    ;;
esac
du -sh "$ARCHIVE"
