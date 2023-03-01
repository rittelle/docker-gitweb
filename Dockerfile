FROM alpine:3.17.0

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
  fcgiwrap \
  git \
  make \
  perl-cgi

# install gitweb
RUN git clone --depth 1 git://git.kernel.org/pub/scm/git/git.git /git-src
WORKDIR /git-src
RUN make GITWEB_PROJECTROOT="/git" gitweb \
  && make gitwebdir=/var/www/cgi-bin install-gitweb

# create an empty directory for the repositories
RUN mkdir /git

EXPOSE 4000/tcp

CMD ["/usr/bin/fcgiwrap", "-s", "tcp:0.0.0.0:4000"]
