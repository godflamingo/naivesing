chmod +x /singo/singo
mkdir /etc/singo
mkdir /usr/local/etc/sing-box
cat << EOF > /etc/singo/config.json
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "naive",
      "tag": "naive-in",
      "network": "tcp",
      "listen": "127.0.0.1",
      "listen_port": 52004,
      "tcp_fast_open": true,
      "sniff": true,
      "sniff_override_destination": false,
      "proxy_protocol": true,
      "proxy_protocol_accept_no_header": false,
      "users": [
        {
          "username": "imlala",
          "password": "password"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "testnaive.lanod.tk",
        "acme": {
          "domain": ["testnaive.lanod.tk"],
          "data_directory": "/usr/local/etc/sing-box",
          "default_server_name": "",
          "email": "imlala@gmail.com",
          "provider": "letsencrypt"
        }
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
# Let's get start
chmod +x /etc/singo/config.json
/singo/singo run -c /etc/singo/config.json
