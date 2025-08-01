FROM quay.io/pypa/manylinux2014_x86_64
COPY entrypoint.sh /entrypoint.sh
RUN yum -y install ninja-build
ENTRYPOINT ["/entrypoint.sh"]
