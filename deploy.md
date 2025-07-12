# execute log
```shell
$ kdeploy execute deploy.rb
          _            _
  /\ /\__| | ___ _ __ | | ___  _   _
 / //_/ _` |/ _ \ '_ \| |/ _ \| | | |
/ __ \ (_| |  __/ |_) | | (_) | |_| |
\/  \/\__,_|\___| .__/|_|\___/ \__, |
                |_|            |___/


⚡ Lightweight Agentless Deployment Tool
🚀 Deploy with confidence, scale with ease

=====================================================================================================

Task: deploy_web

web01 - ✓ Success
  $ free -m
    total        used        free      shared  buff/cache   available
    Mem:            1967         490         272           4        1400        1477
    Swap:              0           0           0

  $ upload_template: ./config/nginx.conf.erb -> /tmp/nginx.conf

  $ ls -l /tmp/nginx.conf
  > cat /tmp/nginx.conf
    -rw------- 1 root root 1147 Jul 12 00:50 /tmp/nginx.conf
    user nginx;
    worker_processes 4;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;
    events {
        worker_connections 2048;
    }
    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
        access_log /var/log/nginx/access.log main;
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        upstream app_servers {
            server 127.0.0.1:3000;
        }
        server {
            listen 80;
            server_name example.com;
            location / {
                proxy_pass http://app_servers;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
            }
            error_page 500 502 503 504 /50x.html;
            location = /50x.html {
                root /usr/share/nginx/html;
            }
        }
    }

  $ uptime
    00:50:39 up 123 days, 14:56,  2 users,  load average: 0.00, 0.01, 0.00
````