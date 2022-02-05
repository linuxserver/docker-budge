FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BUDGE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	nodejs \
	npm \
	sqlite && \
 echo "**** install budge ****" && \
 mkdir -p /app/budge && \
 if [ -z ${NOTEMARKS_RELEASE+x} ]; then \
	BUDGE_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/BudgE/commits/main" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/budge.tar.gz -L \
	"https://github.com/linuxserver/BudgE/archive/${BUDGE_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/budge.tar.gz -C \
	 /app/budge/ --strip-components=1 && \
 echo "**** install backend ****" && \
 cd /app/budge/backend && \
 npm i && \
 npm run build && \
 npm prune --production && \
 echo "**** install ynab importer ****" && \
 cd /app/budge/ynab && \
 npm i && \
 echo "**** install frontend ****" && \
 cd /app/budge/frontend && \
 npm i && \
 npm run build && \
 npm prune --production && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /
