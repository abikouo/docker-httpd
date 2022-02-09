FROM httpd

LABEL author="Aubin Bikouo (@abikouo)"

# Updating System Packages
RUN apt-get update && \
    apt-get upgrade -y

# Check Default Python Version
# RUN python --version

# Install the necessary packages
RUN apt install -y build-essential \
                   zlib1g-dev \
                   libncurses5-dev \
                   libgdbm-dev \
                   libnss3-dev \
                   libssl-dev \
                   libreadline-dev \
                   libffi-dev \
                   wget \
                   python3 \
                   python3-pip \
                   libcap2-bin

# RUN python3 setup.py install

RUN apt install -y apache2 apache2-dev

# mod_wsgi compilation
RUN wget -O /tmp/mod_wsgi.tar.gz https://github.com/GrahamDumpleton/mod_wsgi/archive/refs/tags/4.9.0.tar.gz && \
    tar -C /tmp -xvf /tmp/mod_wsgi.tar.gz && \
    rm /tmp/mod_wsgi.tar.gz

WORKDIR /tmp/mod_wsgi-4.9.0

RUN ./configure --with-python=/usr/bin/python3 --with-apxs=/usr/bin/apxs && \
    make && \
    make install clean

RUN rm -rf /tmp/mod_wsgi-4.9.0

RUN pip3 install WebOb

COPY src/application.wsgi /usr/local/apache2/conf/application.wsgi

COPY ./src/httpd.conf /usr/local/apache2/conf/httpd.conf

EXPOSE 80

RUN setcap 'cap_net_bind_service=+ep' /usr/local/apache2/bin/httpd

RUN useradd ansible

RUN mkdir /mirrors

RUN chown ansible:ansible /usr/local/apache2/logs

RUN chown -R ansible:ansible /mirrors

USER ansible

CMD ["httpd", "-D", "FOREGROUND", "-e", "info"]