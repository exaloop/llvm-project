FROM quay.io/pypa/manylinux2014_aarch64
COPY entrypoint.sh /entrypoint.sh
RUN yum -y install https://linux.mellanox.com/public/repo/doca/2.2.0/centos7.6/aarch64/ninja-build-1.10.2-3.el7.aarch64.rpm
ENTRYPOINT ["/entrypoint.sh"]
