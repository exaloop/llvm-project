#!/bin/sh -l
set -e

WORKSPACE="${1:-/github/workspace}"

export ARCHDEFAULT="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
ARCH=${2:-$ARCHDEFAULT}

echo "Workspace: ${WORKSPACE}; arch: ${ARCH}"
cd "$WORKSPACE"

export COMMIT="$(git rev-parse --short HEAD)"

cmake -S llvm -G Ninja \
  -B llvm/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_ENABLE_ZSTD=OFF \
  -DLLVM_TARGETS_TO_BUILD=all \
  -DLLVM_BUILD_TOOLS=OFF \
  -DLLVM_ENABLE_PROJECTS="clang;openmp"

cmake --build llvm/build

cmake --install llvm/build --prefix=/opt/llvm-codon

touch "/opt/llvm-codon/llvm-codon-${COMMIT}-${ARCH}.version"

tar cjvf llvm-${ARCH}.tar.bz2 -C /opt llvm-codon/
du -sh llvm-${ARCH}.tar.bz2
