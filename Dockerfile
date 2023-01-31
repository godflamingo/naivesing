FROM nginx:1.21.6-alpine
ENV TZ=Asia/Shanghai
RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip php7
ADD singo /singo/singo
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
ENTRYPOINT ["sh", "/configure.sh"]
