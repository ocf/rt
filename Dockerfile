FROM netsandbox/request-tracker-base

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	patch \
        libapache2-mod-auth-openidc \
        libapache2-mod-rpaf \
        libapache2-mod-perl2 \
        default-libmysqlclient-dev \
	msmtp \
	msmtp-mta

RUN cpanm DBD::mysql

WORKDIR /usr/local/src
RUN curl -sSL "https://download.bestpractical.com/pub/rt/release/rt-5.0.0.tar.gz" -o rt.tar.gz \ 
  && tar -xzf rt.tar.gz

WORKDIR /usr/local/src/rt-5.0.0
RUN ./configure \
      --disable-gpg \
      --disable-smime \
    && make install

# These must be installed after RT
RUN cpanm RT::Extension::MergeUsers \
      RT::Extension::CommandByMail \
      RT::Extension::REST2 \
      RT::Extension::Tags \
      Net::LDAP

COPY msmtprc /etc/msmtprc
COPY apache2/ /etc/apache2/
COPY run healthcheck /opt/rt/
COPY 99-ocf.pm /opt/rt5/etc/RT_SiteConfig.d 
RUN a2enmod headers rewrite rpaf auth_openidc
COPY hide-reply-link-for-comments.patch /tmp/
RUN cd / && patch -p1 < /tmp/hide-reply-link-for-comments.patch

ENV SERVER_NAME rt.ocf.berkeley.edu

EXPOSE 80
CMD ["/opt/rt/run"]

