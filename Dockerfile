# RINIS default Centos 7 base image
FROM centos:7 as build

RUN yum -y install wget   

# destination folder of the new os
ARG centos_root=/centos_image/rootfs

# starting to build up my os from scratch
RUN set -eux; \
    mkdir -p ${centos_root} && \
    rpm --root ${centos_root} --initdb && \
    yum reinstall --downloadonly --downloaddir . centos-release && \
    rpm --root ${centos_root} -ivh centos-release*.rpm && \
    rpm --root ${centos_root} --import  ${centos_root}/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# installing mandatory packages
RUN set -eux; yum -y --installroot=${centos_root} \
    --setopt=tsflags='nodocs' \
    --setopt=override_install_langs=en_US.utf8 \
    install \
    yum \
    procps-ng \
    iputils \
    yum-plugin-ovl \
    cups-client \
    ghostscript

# Reduce the size of locale-archive?
RUN rm -rf ${centos_root}/var/cache/yum

# Custom add-ons
ADD dumb-init_1.2.5_x86_64 ${centos_root}/usr/local/bin/dumb-init
RUN chmod +x ${centos_root}/usr/local/bin/dumb-init
RUN ln -sf /usr/share/zoneinfo/Europe/Amsterdam ${centos_root}/etc/localtime

# Papercut addons
RUN wget -O pc-mobility-print.sh https://www.papercut.com/products/ng/mobility-print/download/server/linux/ && \
    dd if="pc-mobility-print.sh" bs=4096 skip=1 | tar xzvfP - && \
    mkdir -p /centos_image/rootfs/home/papercut && \
    mv /tmp/mobilitytemp /centos_image/rootfs/home/papercut/pc-mobility-print && \
    cp /centos_image/rootfs/home/papercut/pc-mobility-print/pc-mobility-print.conf.standalone /centos_image/rootfs/home/papercut/pc-mobility-print/pc-mobility-print.conf && \
    chown -R 1001:1001 /centos_image/rootfs/home/papercut

 


#
#  FINAL CONTAINER
#
FROM scratch
MAINTAINER Ron Blom
LABEL maintainer="Ron Blom blom.ron@gmail.com"

COPY --from=build /centos_image/rootfs /

RUN groupadd -g 1001 papercut && \
    adduser -u 1001 -g 1001 papercut  &&\
    usermod –aG lp papercut

EXPOSE 9163 9164 5353
USER 1001

WORKDIR /home/papercut/pc-mobility-print
#ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
ENTRYPOINT ["/home/papercut/pc-mobility-print/pc-mobility-print", "run"]


#yum install which
#adduser papercut
#su -l papercut
#wget -O pc-mobility-print.sh https://www.papercut.com/products/ng/mobility-print/download/server/linux/
#dd if="pc-mobility-print.sh" bs=4096 skip=1 | tar xzvfP -
#chod +x pc-mobility-print.sh
#./pc-mobility-print.sh -e --non-interactive
#cd pc-mobility-print
#./pc-mobility-print run

