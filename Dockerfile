FROM node:8.12.0-alpine

RUN mkdir /code
WORKDIR /code
ADD package.json /code/
RUN npm install
ADD . /code/

# ------------------------
# SSH Server support
# ------------------------
ENV SSH_PASSWD "root:Docker!"
RUN apk --update add openssl-dev \
    openssh \
    openrc \
    bash \
    && echo "$SSH_PASSWD" | chpasswd 


# Fixing issues from https://github.com/gliderlabs/docker-alpine/issues/42
RUN  \
    # Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
    # Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
    # no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
    # can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
    # can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
    # can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
    # can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh &&\
    # clean apk cache
    rm -rf /var/cache/apk/*
    
COPY sshd_config /etc/ssh/
COPY init_container.sh /code/init_container.sh 
RUN chmod 755 /code/init_container.sh 

EXPOSE 2222 3000
ENV PORT 3000
ENTRYPOINT ["/code/init_container.sh"]