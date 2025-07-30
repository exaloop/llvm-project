#!/bin/sh -l
set -e

WORKSPACE="${1:-/github/workspace}"
echo "Workspace: ${WORKSPACE}"
cd "$WORKSPACE"
ls -lah

export VERSION="$(git describe --tags --abbrev=0)"
export FULL_VERSION="$(git describe --tags --abbrev=0)-$(git rev-parse --short HEAD)"
export ARCH="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"

cmake -S llvm-src/llvm -G Ninja \
  -B llvm-src/llvm/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_TARGETS_TO_BUILD=all \
  -DLLVM_BUILD_TOOLS=OFF \
  -DLLVM_ENABLE_PROJECTS="clang;openmp"

cmake --build llvm-src/llvm/build

cmake --install llvm-src/llvm/build --prefix=/opt/llvm-codon

touch "/opt/llvm-codon/llvm-codon-${FULL_VERSION}-${ARCH}.version"

tar cjvf llvm-${VERSION}-${ARCH}.tar.bz2 -C /opt llvm-codon/
du -sh llvm-${VERSION}-${ARCH}.tar.bz2
