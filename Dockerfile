FROM alpine:3.17.0

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
  git \
  lighttpd \
  make \
  perl-cgi

# copy the lighttpd configuration over
COPY lighttpd /etc/lighttpd

# install gitweb
RUN git clone --depth 1 git://git.kernel.org/pub/scm/git/git.git /git-src
WORKDIR /git-src
RUN make \
    prefix="/usr" \
    gitwebdir=/var/www/cgi-bin \
    GITWEB_PROJECTROOT="/git" \
    install-gitweb

# create a path for html files
RUN mkdir /var/www/htdocs

# create a test file
RUN echo "Hello World!" >>/var/www/htdocs/index.html

# create an empty directory for the repositories
RUN mkdir /git

WORKDIR /

EXPOSE 80/tcp

CMD ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
