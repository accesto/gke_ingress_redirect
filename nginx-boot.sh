#!/bin/bash

# Check for variables
export WORKER_CONNECTIONS=${WORKER_CONNECTIONS:-1024}
export HTTP_PORT=${HTTP_PORT:-80}
export REDIRECT=${REDIRECT:-https\:\/\/\$host}
export REDIRECT_TYPE=${REDIRECT_TYPE:-permanent}
export NGINX_CONF=/etc/nginx/mushed.conf
export HSTS=${HSTS:-0}
export HSTS_MAX_AGE=${HSTS_MAX_AGE:-31536000}
export HSTS_INCLUDE_SUBDOMAINS=${HSTS_INCLUDE_SUBDOMAINS:-0}

# Build config
cat <<EOF > $NGINX_CONF
user root;
daemon off;

events {
    worker_connections $WORKER_CONNECTIONS;
}



http {
    access_log /dev/stdout;
    error_log /dev/stdout info;

    geo \$ingress {
        default 0;
        10.0.0.0/8 1;
    }

    server {
        listen $HTTP_PORT;
        server_tokens off;

        if (\$ingress) {
            return 200 'ok';
        }
        $([ "${HSTS}" != "0" ] && echo "
        add_header Strict-Transport-Security \"max-age=${HSTS_MAX_AGE};$([ "${HSTS_INCLUDE_SUBDOMAINS}" != "0"] && echo "includeSubDomains")\";
        ")
        rewrite ^(.*) $REDIRECT\$1 $REDIRECT_TYPE;
    }
}

EOF

cat $NGINX_CONF;

chown -R root:root /var/lib/nginx;
mkdir -p /run/nginx;

exec nginx -c $NGINX_CONF
