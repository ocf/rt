FROM docker.ocf.berkeley.edu/theocf/debian:bookworm

RUN apt-get update && apt-get -y upgrade && apt-get -y install --no-install-recommends \
    cpanminus \
    curl \
    gcc \
    gnupg \
    graphviz \
    vim \
    # RT core dependencies
    libapache-session-perl \
    libbusiness-hours-perl \
    libc-dev \
    libcgi-emulate-psgi-perl \
    libcgi-psgi-perl \
    libconvert-color-perl \
    libcrypt-eksblowfish-perl \
    libcrypt-ssleay-perl \
    libcrypt-x509-perl \
    libcss-minifier-xs-perl \
    libcss-squish-perl \
    libdata-guid-perl \
    libdata-ical-perl \
    libdata-page-pageset-perl \
    libdata-page-perl \
    libdate-extract-perl \
    libdate-manip-perl \
    libdatetime-format-natural-perl \
    libdbd-sqlite3-perl \
    libdbix-searchbuilder-perl \
    libdevel-globaldestruction-perl \
    libemail-address-list-perl \
    libemail-address-perl \
    libencode-detect-perl \
    libencode-hanextra-perl \
    libencode-perl \
    libfile-sharedir-perl \
    libgd-graph-perl \
    libgnupg-interface-perl \
    libgraphviz-perl \
    libhtml-formatexternal-perl \
    libhtml-formattext-withlinks-andtables-perl \
    libhtml-formattext-withlinks-perl \
    libhtml-gumbo-perl \
    libhtml-mason-psgihandler-perl \
    libhtml-quoted-perl \
    libhtml-rewriteattributes-perl \
    libhtml-scrubber-perl \
    libipc-run3-perl \
    libjavascript-minifier-xs-perl \
    libjson-perl \
    liblocale-maketext-fuzzy-perl \
    liblocale-maketext-lexicon-perl \
    liblog-dispatch-perl \
    libmailtools-perl \
    libmime-tools-perl \
    libmime-types-perl \
    libmodule-path-perl \
    libmodule-refresh-perl \
    libmodule-signature-perl \
    libmodule-versions-report-perl \
    libmoose-perl \
    libmoosex-nonmoose-perl \
    libmoosex-role-parameterized-perl \
    libnet-cidr-perl \
    libnet-ip-perl \
    libnet-ldap-perl \
    libparallel-forkmanager-perl \
    libpath-dispatcher-perl \
    libperlio-eol-perl \
    libplack-perl \
    libregexp-common-net-cidr-perl \
    libregexp-common-perl \
    libregexp-ipv6-perl \
    librole-basic-perl \
    libscope-upper-perl \
    libsymbol-global-name-perl \
    libterm-readkey-perl \
    libtext-password-pronounceable-perl \
    libtext-quoted-perl \
    libtext-template-perl \
    libtext-wikiformat-perl \
    libtext-worddiff-perl \
    libtext-wrapper-perl \
    libtime-parsedate-perl \
    libtree-simple-perl \
    libuniversal-require-perl \
    libweb-machine-perl \
    libxml-rss-perl \
    make \
    perl-doc \
    starlet \
    w3m \
    # RT developer dependencies
    libemail-abstract-perl \
    libfile-which-perl \
    liblocale-po-perl \
    liblog-dispatch-perl-perl \
    libmodule-install-perl \
    libmojolicious-perl \
    libnet-ldap-server-test-perl \
    libplack-middleware-test-stashwarnings-perl \
    libset-tiny-perl \
    libstring-shellquote-perl \
    libtest-deep-perl \
    libtest-email-perl \
    libtest-expect-perl \
    libtest-longstring-perl \
    libtest-mocktime-perl \
    libtest-nowarnings-perl \
    libtest-pod-perl \
    libtest-warn-perl \
    libtest-www-mechanize-perl \
    libtest-www-mechanize-psgi-perl \
    libwww-mechanize-perl \
    libxml-simple-perl \
  && cpanm \
    # RT dependencies
    DBIx::SearchBuilder \
    GnuPG::Interface \
    Mozilla::CA \
    Pod::Select \
    # RT extension development dependencies
    Module::Install::RTx \
    Module::Install::Substitute \
  && rm -rf /root/.cpanm

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	    patch \
      libapache2-mod-auth-openidc \
      libapache2-mod-rpaf \
      libapache2-mod-perl2 \
	    apache2 \
      default-libmysqlclient-dev \
	    msmtp \
	    msmtp-mta \
	    libfcgi-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm DBD::mysql

WORKDIR /usr/local/src
RUN curl -sSL "https://download.bestpractical.com/pub/rt/release/rt-5.0.4.tar.gz" -o rt.tar.gz \ 
  && tar -xzf rt.tar.gz

WORKDIR /usr/local/src/rt-5.0.4
RUN ./configure \
      --disable-gpg \
      --disable-smime \
    && make install

# These must be installed after RT
RUN cpanm RT::Extension::MergeUsers \
      RT::Extension::CommandByMail \
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
