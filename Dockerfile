FROM docker.ocf.berkeley.edu/theocf/debian:jessie

COPY request-tracker4.preseed /tmp/request-tracker4.preseed
RUN debconf-set-selections /tmp/request-tracker4.preseed
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apache2 \
        cpanminus \
        libapache2-mod-auth-kerb \
        libapache2-mod-rpaf \
        # For building RT modules from CPAN
        make \
        request-tracker4 \
        rt4-apache2 \
        rt4-db-mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm install RT::Extension::MergeUsers \
    && cpanm install RT::Extension::CommandByMail \
    && update-rt-siteconfig-4
COPY apache2/ /etc/apache2/
COPY run /opt/rt/
COPY 99-ocf /etc/request-tracker4/RT_SiteConfig.d/
RUN a2enmod headers rewrite rpaf

EXPOSE 80
CMD ["/opt/rt/run"]
