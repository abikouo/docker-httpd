FROM centos:centos7

LABEL maintainer="Aubin Bikouo (@abikouo)"

RUN yum install -y \
        openssl-devel \
        git \
        make \
        gcc \
        gcc-c++ \
        wget

WORKDIR /squid

RUN wget -O - http://www.squid-cache.org/Versions/v4/squid-4.15.tar.gz | tar zxfv -

RUN cd squid-4.15 \
    && ./configure --prefix=/apps/squid \
            --enable-icap-client \
            --enable-ssl \
            --with-openssl \
            --enable-ssl-crtd  \
            --enable-url-rewrite-helpers="fake" \
    && make -j4 \
    && make install

WORKDIR /apps

RUN rm -rf /squid

COPY squid.conf /apps/squid.conf

# init ssl_db
RUN /apps/squid/libexec/security_file_certgen -c -s /apps/squid/var/cache/squid/ssl_db -M 4MB

# init cache dir
RUN mkdir -p /apps/squid/var/cache/squid/cache

# install openssl used to generate certificate
RUN yum install -y openssl

COPY openssl.conf /apps/openssl.conf

COPY entrypoint.sh /apps/entrypoint.sh

RUN chmod +x entrypoint.sh

EXPOSE 3128

VOLUME /apps/ssl_cert

RUN chown -R nobody /apps

ENTRYPOINT ["/apps/entrypoint.sh"]