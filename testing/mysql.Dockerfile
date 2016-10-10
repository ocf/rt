# A MySQL database with RT fixtures loaded.
FROM docker.ocf.berkeley.edu/theocf/debian:jessie

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mysql-server \
        request-tracker4 \
        rt4-db-mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY 98-ocfdb /etc/request-tracker4/RT_SiteConfig.d/98-ocfdb
COPY install-fixtures /root/

RUN update-rt-siteconfig-4
RUN /root/install-fixtures

CMD ["mysqld"]

# vim: ft=Dockerfile
