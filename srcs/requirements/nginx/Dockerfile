# Base image: Debian Bookworm (stable version used in Inception)
FROM debian:bookworm

# Install nginx (the web server) and openssl (to generate the SSL certificate)
# We chain the commands in a single RUN to avoid creating unnecessary image layers
# rm -rf /var/lib/apt/lists/* cleans the package cache to keep the image small
RUN apt-get update && apt-get install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

# Generate a self-signed SSL certificate valid for 365 days
# -x509		: generate a certificate directly (not a certificate signing request)
# -noenc	: no password on the private key (replaces deprecated -nodes since OpenSSL 3.0)
# -days 365	: certificate valid for 1 year
# -newkey rsa:2048	: generate a new RSA 2048-bit private key at the same time
# -out		: where to save the certificate (.crt)
# -keyout	: where to save the private key (.key)
# -subj		: certificate subject — CN is the domain name the certificate is for
RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
	-out /etc/ssl/certs/nginx.crt \
	-keyout /etc/ssl/private/nginx.key \
	-subj "/CN=doley.42.fr"

# Copy our custom nginx config into the container
# This replaces the default nginx.conf entirely
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Document that this container listens on port 443 (HTTPS)
# This is informational only — docker-compose actually opens the port
EXPOSE 443

# Start nginx in the foreground (daemon off) so it stays as PID 1
# Using exec form ["..."] to avoid wrapping nginx in a shell process
CMD ["nginx", "-g", "daemon off;"]
