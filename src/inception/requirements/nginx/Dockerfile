FROM alpine:3.19

RUN apk update && apk add nginx openssl

# Create necessary directories
RUN mkdir -p /var/www/html /run/nginx /etc/ssl/private /etc/ssl/certs

# Generate SSL certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/odakhch.key \
    -out /etc/ssl/certs/odakhch.crt \
    -subj "/C=MA/ST=Beni Mellal-Khenifra/L=tanger/O=1337/OU=sel-kham/CN=marinadberr.duckdns.org"

# Remove default config and copy custom one
RUN rm -f /etc/nginx/http.d/default.conf
COPY ./conf/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]