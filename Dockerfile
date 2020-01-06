FROM redis:alpine
MAINTAINER Tomoiida <tomoiida@gmail.com>

RUN { \
  echo -e 'cluster-enabled      yes\n \
    cluster-config-file  nodes.conf\n \
    cluster-node-timeout 5000' > /etc/redis.conf && \
  echo -e '#!/bin/ash\n \
    redis-server /etc/redis.conf --port 6379 &\n\
    mkdir sub1\ncd sub1\n\
    redis-server /etc/redis.conf --port 6380 &\n\
    cd ..\n\
    mkdir sub2\ncd sub2\n\
    redis-server /etc/redis.conf --port 6381 &\n\
    redis-cli -p 6379 cluster addslots $(seq 0 5500)\n\
    redis-cli -p 6380 cluster addslots $(seq 5501 11000)\n\
    redis-cli -p 6381 cluster addslots $(seq 11001 16383)\n\
    redis-cli -p 6380 cluster meet 127.0.0.1 6379\n\
    redis-cli -p 6381 cluster meet 127.0.0.1 6379\n\
    \n \
    exec "$@"' \
    > /usr/local/bin/docker-entrypoint.sh; \
  }

CMD ["tail", "-f", "/dev/null"]
EXPOSE 6379 
EXPOSE 6380 
EXPOSE 6381
