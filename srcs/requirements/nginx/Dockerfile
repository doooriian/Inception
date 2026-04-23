FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*


RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
	-out /etc/ssl/certs/nginx.crt \
	-keyout /etc/ssl/private/nginx.key \
	-subj "/CN=doley.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off"]
