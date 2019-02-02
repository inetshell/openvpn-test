FROM centos:7
MAINTAINER Manuel Carrillo "inetshell@gmail.com"

ENV OPENVPN_VERSION openvpn-2.4.5

WORKDIR /tmp

COPY entrypoint.sh /entrypoint.sh
COPY ${OPENVPN_VERSION} /tmp/${OPENVPN_VERSION}/

RUN ls /tmp
RUN ls /tmp/${OPENVPN_VERSION}/
