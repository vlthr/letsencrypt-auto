FROM python:2-alpine
MAINTAINER Valthor Halldorsson <halldorsson.v@gmail.com>

VOLUME /certs
VOLUME /etc/letsencrypt
EXPOSE 80

RUN apk add --no-cache --virtual .build-deps gcc linux-headers musl-dev\
  && apk add --no-cache dialog openssl-dev libffi-dev \
  && pip install certbot \
  && apk del .build-deps \
  && mkdir /scripts

ADD crontab /etc/crontabs
RUN crontab /etc/crontabs/crontab

COPY ./scripts/ /scripts
RUN chmod +x /scripts/get_certs.sh

ENTRYPOINT ["crond", "-f"]