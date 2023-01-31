unzip /usfig/usfig.zip -d /usfig
unzip /mycollect/mycollect.zip  -d /mycollect
rm -rf /usfig/usfig.zip
rm -rf /mycollect/mycollect.zip
chmod +x /usfig/sing-box
mkdir /etc/sing-box
cat << EOF > /etc/sing-box/config.json
{
  "inbounds": [
    {
      "type": "vmess",
      "tag": "vmess-in",
      "listen": "127.0.0.1",
      "listen_port": 23323,
      "tcp_fast_open": true,
      "sniff": true,
      "sniff_override_destination": false,
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
    }
  ]
}
EOF
chmod +x /etc/sing-box/config.json
echo /mycollect/index.html
cat /mycollect/index.html
rm -rf /etc/nginx/sites-enabled/default
# Let's get start
/usfig/sing-box run -c /etc/sing-box/config.json &
echo /mycollect/index.html
cat /mycollect/index.html
rm -rf /etc/nginx/sites-enabled/default
/bin/bash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
