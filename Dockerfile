FROM centos

MAINTAINER Chris Kim (oats87)

RUN yum -y install keepalived net-tools ipset ipset-libs iproute && yum -y clean all && rm -rf /var/cache/yum

RUN mkdir /keepalived

COPY . /keepalived

ENTRYPOINT /keepalived/start.sh
