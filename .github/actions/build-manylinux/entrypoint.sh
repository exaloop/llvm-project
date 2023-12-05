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
    -DLLVM_TARGETS_TO_BUILD=all \
    -DLLVM_ENABLE_LIBEDIT=OFF
cmake --build build-llvm
cmake --install build-llvm --prefix=/opt/llvm-codon

cmake -S clang -B build-clang -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_LIBEDIT=OFF
cmake --build build-clang
cmake --install build-clang --prefix=/opt/llvm-codon

export LLVM_BUILD_ARCHIVE=llvm-$(uname -s | awk '{print tolower($0)}')-$(uname -m).tar.gz
tar -czf ${LLVM_BUILD_ARCHIVE} /opt/llvm-codon
echo "Done"
