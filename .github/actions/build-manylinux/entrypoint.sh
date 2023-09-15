#!/bin/sh -l
set -e

# setup
cd /github/workspace
yum -y update
yum -y install ninja-build

# compile LLVM
cmake -S llvm -B build-llvm -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_TARGETS_TO_BUILD=all
cmake --build build-llvm
cmake --install build-llvm --prefix=/github/llvm-codon

cmake -S clang -B build-clang -G Ninja \
    -DCMAKE_BUILD_TYPE=Release
cmake --build build-clang
cmake --install build-clang --prefix=/github/llvm-codon

export LLVM_BUILD_ARCHIVE=llvm-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz
tar -czf ${LLVM_BUILD_ARCHIVE} /github/llvm-codon
echo "Done"
