FROM node:10.13.0-alpine

LABEL maintainer "inotom"
LABEL title="wp-dev"
LABEL version="3"
LABEL description="WordPress/Node.js development environment with Docker"

ENV HOME=/home/app
ENV PATH=$HOME/.npm-global/bin:$PATH
ENV PATH=./node_modules/.bin:$PATH
ENV PATH=$HOME/.composer/vendor/bin:$PATH

# shadow packages (https://pkgs.alpinelinux.org/contents?file=&path=&name=shadow&branch=v3.5&repo=community&arch=x86_64)
RUN \
  apk update \
  && apk add --no-cache sudo shadow zip unzip tzdata git build-base curl php7 php7-json php7-phar php7-iconv php7-mbstring php7-openssl php7-simplexml php7-tokenizer php7-xmlwriter \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && apk del tzdata \
  && useradd --user-group --create-home --shell /bin/false app \
  && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && curl -sS https://getcomposer.org/installer | php7 -- --install-dir=/usr/local/bin --filename=composer \
  && composer global require squizlabs/php_codesniffer:3.3.\* \
  && git clone -b 1.1.0 https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /usr/local/etc/wpcs \
  && phpcs --config-set installed_paths /usr/local/etc/wpcs

WORKDIR $HOME/work

COPY package.json package-lock.json .npmrc $HOME/work/
RUN \
  chown -R app:app $HOME/*

USER app
WORKDIR $HOME/work
RUN \
  mkdir $HOME/.npm-global \
  && npm config set prefix $HOME/.npm-global \
  && npm install -g npm@6.4.1 \
  && npm cache verify \
  && mkdir node_modules
