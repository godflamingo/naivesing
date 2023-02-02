FROM nginx:1.23.3-alpine
ENV TZ=Asia/Shanghai
RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip wget openssl
expose 80
ADD apt/default.conf.template /etc/nginx/conf.d/default.conf.template
ADD apt/nginx.conf /etc/nginx/nginx.conf
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
ENTRYPOINT ["sh", "/configure.sh"]
