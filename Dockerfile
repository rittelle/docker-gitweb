# the first stage prepares /var/www
FROM alpine:3.17.0

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
  git \
  make

# create a path for html files
RUN mkdir -p /var/www/htdocs

# install gitweb
RUN git clone --depth 1 git://git.kernel.org/pub/scm/git/git.git /git-src
WORKDIR /git-src
RUN make \
    prefix="/usr" \
    gitwebdir=/var/www/cgi-bin \
    GITWEB_PROJECTROOT="/git" \
    install-gitweb

# the final stage provides the final image
FROM alpine:3.17.0

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
  git \
  lighttpd \
  perl-cgi

# copy gitweb over
COPY --from=0 /var/www/ /var/www

# copy the lighttpd configuration over
COPY lighttpd /etc/lighttpd

# create an empty directory for the repositories
RUN mkdir /git

EXPOSE 80/tcp

CMD ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
