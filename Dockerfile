FROM centos:7
MAINTAINER Manuel Carrillo "inetshell@gmail.com"

ENV OPENVPN_VERSION="openvpn-2.4.5" \
    DHPARAM_SIZE="1024" \
    SCRIPT_SECURITY="3" \
    KEEPALIVE="10 20" \
    PROTO="tcp4-server" \
    CIPHER="AES-256-CBC" \
    NCP_CIPHERS="AES-256-GCM:AES-256-CBC" \
    AUTH="SHA512" \
    SERVER="192.168.112.0 255.255.240.0" \
    LPORT="1194" \
    MAX_CLIENTS="4096" \
    COMP_LZO="yes" \
    TOPOLOGY="subnet" \
    SCRAMBLE="reverse"

WORKDIR /tmp

COPY openvpn.conf.j2 /root/openvpn.conf.j2
COPY ${OPENVPN_VERSION}/ /tmp/${OPENVPN_VERSION}/
COPY entrypoint.sh /entrypoint.sh

RUN \
# Update YUM cache
  yum install -y epel-release && \
  yum update -y && \
# Install dependencies and clean YUM cache
  yum install -y iptables autoconf.noarch automake file gcc libtool patch quilt git make rpm-build zlib-devel pam-devel openssl openssl-devel lzo-devel lz4-devel.x86_64 net-tools cmake.x86_64 && \
  yum clean all && \
  cd ${OPENVPN_VERSION}/ && \
# Build OpenVPN
  autoreconf -i -v -f && \
  ./configure && \
  make && \
  make install && \
# Remove working directory
  rm -rf /tmp/* && \
# Create openvpn config directory
  mkdir /etc/openvpn && \
# Set permissions to entrypoint.sh
  chmod u+x /entrypoint.sh

EXPOSE 1194

ENTRYPOINT ["/entrypoint.sh"]
