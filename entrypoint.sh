#!/bin/bash -x
OPENVPN_CONF="/etc/openvpn/server.conf"
DHPARAM_PATH="/etc/openvpn/dhparam.pem"

echo "Generating openvpn.conf"
cp "/root/openvpn.conf.j2" "${OPENVPN_CONF}"
sed -e "s:{{ SCRIPT_SECURITY }}:${SCRIPT_SECURITY}:" \
    -e "s:{{ KEEPALIVE }}:${KEEPALIVE}:" \
    -e "s:{{ PROTO }}:${PROTO}:" \
    -e "s:{{ CIPHER }}:${CIPHER}:" \
    -e "s:{{ NCP_CIPHERS }}:${NCP_CIPHERS}:" \
    -e "s:{{ AUTH }}:${AUTH}:" \
    -e "s:{{ SERVER }}:${SERVER}:" \
    -e "s:{{ LPORT }}:${LPORT}:" \
    -e "s:{{ MAX_CLIENTS }}:${MAX_CLIENTS}:" \
    -e "s:{{ COMP_LZO }}:${COMP_LZO}:" \
    -e "s:{{ TOPOLOGY }}:${TOPOLOGY}:" \
    -e "s:{{ SCRAMBLE }}:${SCRAMBLE}:"
    -i "${OPENVPN_CONF}"

if [[ -f "${DHPARAM_PATH}" ]]; then
    echo "DHPARAM file exists"
else
    echo "Generating DHPARAM file"
    openssl dhparam -out "${DHPARAM_PATH}" "${DHPARAM_SIZE}"
fi

echo "Generating cert files"
if [[ -z ${BASE64_CA_CRT} ]] || [[ -z ${BASE64_SERVER_CRT} ]] || [[ -z ${BASE64_SERVER_KEY} ]] || [[ -z ${BASE64_TLS_AUTH} ]]; then
    echo "${BASE64_CA_CRT}" | base64 -d > "/etc/openvpn/ca.crt"
    chmod 700 "/etc/openvpn/ca.crt"

    echo "${BASE64_SERVER_CRT}" | base64 -d > "/etc/openvpn/server.crt"
    chmod 700 "/etc/openvpn/server.crt"

    echo "${BASE64_SERVER_KEY}" | base64 -d > "/etc/openvpn/server.key"
    chmod 700 "/etc/openvpn/server.key"

    echo "${BASE64_TLS_AUTH}" | base64 -d > "/etc/openvpn/tls_auth"
    chmod 700 "/etc/openvpn/tls_auth"
fi

echo "Adding firewall rules"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o ovpns1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ovpns1 -o eth0 -j ACCEPT

echo "Run OpenVPN service"
/usr/local/sbin/openvpn --config "${OPENVPN_CONF}"
