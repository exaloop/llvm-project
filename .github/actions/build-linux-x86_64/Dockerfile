FROM quay.io/pypa/manylinux2014_x86_64
COPY build-llvm.sh /build-llvm.sh
RUN yum -y install ninja-build
CMD bash /build-llvm.sh codon / /opt /mnt
