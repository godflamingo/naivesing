#binary install path
BINARY_FILE_PATH='/usr/local/bin/sing-box'
#config install path
CONFIG_FILE_PATH='/usr/local/etc/sing-box'
DOWNLAOD_PATH='/usr/local/sing-box'
#log file save path
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/sing-box/sing-box.log'
NGINX_CONF_PATH="/etc/nginx/conf.d/"

SING_BOX_VERSION_TEMP=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
SING_BOX_VERSION=${SING_BOX_VERSION_TEMP:1}
echo "将选择使用版本:${SING_BOX_VERSION}"
DOWANLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION_TEMP}/sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz"

#here we need create directory for sing-box
mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
wget -q -O ${DOWNLAOD_PATH}/sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz ${DOWANLOAD_URL}
cd ${DOWNLAOD_PATH}
tar -xvf sing-box-${SING_BOX_VERSION}-linux-amd64v3.tar.gz && cd sing-box-${SING_BOX_VERSION}-linux-amd64v3
install -m 755 sing-box ${BINARY_FILE_PATH}
  if [[ $? -ne 0 ]]; then
    echo "install sing-box failed,exit"
    exit 1
  else
    echo "安装sing-box成功"
  fi
chmod +x /${BINARY_FILE_PATH}
cat << EOF > ${CONFIG_FILE_PATH}/config.json
{
    "dns": {
        "servers": [
            {
                "tag": "google-tls",
                "address": "local",
                "address_strategy": "prefer_ipv4",
                "strategy": "ipv4_only",
                "detour": "direct"
            },
            {
                "tag": "google-udp",
                "address": "8.8.8.8",
                "address_strategy": "prefer_ipv4",
                "strategy": "prefer_ipv4",
                "detour": "direct"
            }
        ],
        "strategy": "prefer_ipv4",
        "disable_cache": false,
        "disable_expire": false
    },
    "inbounds": [
        {
            "type": "vmess",
            "tag": "vmess-in",
            "listen": "0.0.0.0",
            "listen_port": 23323,
            "tcp_fast_open": true,
            "sniff": true,
            "sniff_override_destination": false,
            "domain_strategy": "prefer_ipv4",
            "proxy_protocol": false,
            "users": [
                {
                    "name": "imlala",
                    "uuid": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a",
                    "alterId": 0
                }
            ],
            "tls": {},
            "transport": {
                "type": "ws",
                "path": "/app"
            }
        }  
    ],
    "outbounds": [
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        },
        {
            "type": "dns",
            "tag": "dns-out"
        }
    ],
    "route": {
        "rules": [
            {
                "protocol": "dns",
                "outbound": "dns-out"
            },
            {
                "inbound": [
                    "vmess-in"
                ],
                "geosite": [
                    "cn",
                    "category-ads-all"
                ],
                "geoip": "cn",
                "outbound": "block"
            }
        ],
        "geoip": {
            "path": "geoip.db",
            "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
            "download_detour": "direct"
        },
        "geosite": {
            "path": "geosite.db",
            "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
            "download_detour": "direct"
        },
        "final": "direct",
        "auto_detect_interface": true
    }
}
EOF
mkdir -p /usr/share/nginx/html
wget -c -P /usr/share/nginx "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/fodder/blog/unable/html8.zip" >/dev/null
unzip -o "/usr/share/nginx/html8.zip" -d /usr/share/nginx/html >/dev/null
rm -f "/usr/share/nginx/html8.zip*"
ls -a /usr/share/nginx/html/
rm -rf /etc/nginx/sites-enabled/default
# Let's get start
${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json &
/bin/bash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
