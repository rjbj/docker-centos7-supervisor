# Base image to use, this must be set as the first line
FROM centos:7.4.1708

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
MAINTAINER wanxin <258621580@qq.com>

# 替换yum源为阿里云的，增加包下载的速度
RUN yum install -y wget \
	&& wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
	&& yum clean all && yum makecache

# 安装需要的软件包
RUN yum install -y passwd openssl openssh-server zip python-setuptools
# 安装supervisor
RUN easy_install supervisor

# 配置supervisor
RUN mkdir -p /var/log/supervisor
COPY config/supervisord.conf /etc/supervisord.conf

# 配置允许root用户ssh登录
RUN mkdir -p /var/run/sshd
RUN echo "root:123456" | chpasswd
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''
RUN sed -ri "s/^PermitRootLogin\s+.*/PermitRootLogin yes/" /etc/ssh/sshd_config
RUN sed -ri "s/UsePAM yes/#UsePAM yes/g" /etc/ssh/sshd_config

EXPOSE 22 8080

# 用supervisor启动相关服务
CMD ["/usr/bin/supervisord"]