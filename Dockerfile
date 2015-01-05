FROM ubuntu:14.04
MAINTAINER Juan Fraire <groteck@gmail.com>

RUN apt-get update && apt-get upgrade

RUN apt-get install default-jdk git curl phantomjs gawk g++ gcc make libc6-dev \
  libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 bison ruby wget\
  autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev -y

ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.0

ENV NODE_VERSION 2.2.0

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/ruby \
  && curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    | tar -xjC /usr/src/ruby --strip-components=1 \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && apt-get purge -y --auto-remove bison ruby \
  && make install \
  && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD [ "irb" ]

# Install Node.js
RUN \
  cd /tmp && \
  wget "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz" && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]
