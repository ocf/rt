FROM docker.ocf.berkeley.edu/theocf/debian:stretch

COPY request-tracker4.preseed /tmp/request-tracker4.preseed
RUN debconf-set-selections /tmp/request-tracker4.preseed
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apache2 \
        cpanminus \
        libapache2-mod-authnz-pam \
        libapache2-mod-rpaf \
        libapache2-mod-perl2 \
        # The next two are for building RT modules from CPAN
        libmodule-install-perl \
        libpam-krb5 \
        make \
        patch \
        request-tracker4 \
        rt4-apache2 \
        rt4-db-mysql \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm RT::Extension::MergeUsers \
          RT::Extension::CommandByMail \
          RT::Extension::Tags \
          MasonX::Profiler

COPY apache2/ /etc/apache2/
COPY run healthcheck /opt/rt/
RUN echo "ocfstaff\nopstaff" > /opt/rt/allowed-groups
COPY rt_pam /etc/pam.d/rt
COPY 99-ocf.pm /etc/request-tracker4/RT_SiteConfig.d/
RUN a2enmod headers rewrite rpaf
COPY hide-reply-link-for-comments.patch /tmp/
RUN cd /usr/share/request-tracker4 && patch -p2 < /tmp/hide-reply-link-for-comments.patch

ENV SERVER_NAME rt.ocf.berkeley.edu

EXPOSE 80
CMD ["/opt/rt/run"]
