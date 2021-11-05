FROM debian:latest
########################################
#              Settings                #
########################################
# Syncthing-Relay Server
ENV RELAY_PORT     22067
ENV RELAY_OPTS     ""
# to enable the status interface add ' -p 22070:22070' to you docker command
ENV STATUS_PORT     22070

# 10 mbps
ENV RATE_GLOBAL     10000000
# 500 kbps
ENV RATE_SESSION    500000

ENV TIMEOUT_MSG     1m45s
ENV TIMEOUT_NET     3m30s
ENV PING_INT        1m15s

ENV PROVIDED_BY     "syncthing-relay"
# leave empty for private relay use "https://relays.syncthing.net/endpoint" for public relay
ENV POOLS           ""

# Syncthing-Discovery Server
ENV DISCO_PORT      22026
ENV DISCO_OPTS      ""

########################################
#               Setup                  #
########################################
ENV USERNAME syncthing
ENV USERGROUP syncthing
ENV APPUID 1000
ENV APPGID 1000
ENV USER_HOME /home/syncthing
ENV BUILD_REQUIREMENTS curl
ENV REQUIREMENTS ca-certificates openssl supervisor
########################################

########################################
#               Build                  #
########################################
ARG RELAY_VERSION="v1.15.0"
ARG DISCO_VERSION="v1.18.1"
ARG RELAY_DOWNLOADURL="https://github.com/syncthing/relaysrv/releases/download/v1.15.0/strelaysrv-linux-amd64-v1.15.0.tar.gz"
ARG DISCO_DOWNLOADURL="https://github.com/syncthing/discosrv/releases/download/v1.18.1/stdiscosrv-linux-amd64-v1.18.1.tar.gz"
ARG BUILD_DATE="2021-11-05T15:10:08Z"
########################################

USER root
ENV DEBIAN_FRONTEND noninteractive
# setup
RUN apt-get update -qqy \
	&& apt-get -qqy --no-install-recommends install ${BUILD_REQUIREMENTS} ${REQUIREMENTS} \
	&& mkdir -p ${USER_HOME} \
	&& mkdir -p /var/log/supervisor

# install server
WORKDIR /tmp/
RUN curl -Ls ${RELAY_DOWNLOADURL} --output relaysrv.tar.gz \
		&& curl -Ls ${DISCO_DOWNLOADURL} --output discosrv.tar.gz \
		&& tar -zxf relaysrv.tar.gz \
		&& tar -zxf discosrv.tar.gz \
		&& rm relaysrv.tar.gz \
		&& rm discosrv.tar.gz \
		&& mkdir -p ${USER_HOME}/server ${USER_HOME}/certs ${USER_HOME}/db \
		&& cp /tmp/*relaysrv*/*relaysrv ${USER_HOME}/server/relaysrv \
		&& cp /tmp/*discosrv*/*discosrv ${USER_HOME}/server/discosrv \
		&& apt-get --auto-remove -y purge ${BUILD_REQUIREMENTS} \
		&& rm -rf /var/lib/apt/lists/* \
		&& rm -rf /tmp/*

# supervisor
COPY supervisord.conf ${USER_HOME}/supervisord.conf
COPY start_relay.sh ${USER_HOME}/server/start_relay.sh
COPY start_discovery.sh ${USER_HOME}/server/start_discovery.sh
RUN chmod +x ${USER_HOME}/server/start_relay.sh ${USER_HOME}/server/start_discovery.sh \
		&& groupadd --system --gid ${APPGID} ${USERGROUP} \
		&& useradd --system --uid ${APPUID} -g ${USERGROUP} ${USERNAME} --home ${USER_HOME} \
		&& echo "${USERNAME}:$(openssl rand 512 | openssl sha256 | awk '{print $2}')" | chpasswd \
		&& chown -R ${USERNAME}:${USERGROUP} ${USER_HOME}

EXPOSE ${STATUS_PORT} ${RELAY_PORT} ${DISCO_PORT}
VOLUME ${USER_HOME}/certs

USER $USERNAME
WORKDIR ${USER_HOME}/server/
CMD /usr/bin/supervisord -c "${USER_HOME}/supervisord.conf"
