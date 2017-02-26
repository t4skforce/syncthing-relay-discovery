FROM debian:latest
########################################
#              Settings                #
########################################
ENV DEBUG           false

# Syncthing-Relay Server
ENV RELAY_PORT     22067
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

# Allowed average package rate, per 10 s
ENV LIMIT_AVG       10
# Allowed burst size, packets
ENV LIMIT_BURST     20
# Limiter cache entries
ENV LIMIT_CACHE     25000

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

USER root
ENV DEBIAN_FRONTEND noninteractive
# setup
RUN apt-get update -qqy \
	&& apt-get -qqy --no-install-recommends install ${BUILD_REQUIREMENTS} ${REQUIREMENTS} \
	&& mkdir -p ${USER_HOME} \
	&& mkdir -p /var/log/supervisor

# install server
WORKDIR /tmp/
RUN curl -Ls $(curl -Ls https://api.github.com/repos/syncthing/relaysrv/releases/latest | egrep "browser_download_url.*relaysrv-linux-amd64.*.gz" | cut -d'"' -f4) --output relaysrv.tar.gz \
		&& curl -Ls $(curl -Ls https://api.github.com/repos/syncthing/discosrv/releases/latest | egrep "browser_download_url.*discosrv-linux-amd64.*.gz" | cut -d'"' -f4) --output discosrv.tar.gz \
		&& tar -zxf relaysrv.tar.gz \
		&& tar -zxf discosrv.tar.gz \
		&& rm relaysrv.tar.gz \
		&& rm discosrv.tar.gz \
		&& mkdir -p ${USER_HOME}/server ${USER_HOME}/certs ${USER_HOME}/db \
		&& cp /tmp/*relaysrv*/*relaysrv ${USER_HOME}/server/relaysrv \
		&& cp /tmp/*discosrv*/*discosrv ${USER_HOME}/server/discosrv \
		&& apt-get --auto-remove -y purge ${BUILD_REQUIREMENTS} \
		&& rm -rf /var/lib/apt/lists/* \
		rm -rf /tmp/*

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
