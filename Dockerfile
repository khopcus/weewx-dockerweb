FROM --platform=$TARGETPLATFORM python:2.7-alpine

ARG WEEWX_UID=995
ENV WEEWX_HOME="/home/weewx"
ENV WEEWX_VERSION="3.9.2"
ENV ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"

RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

RUN apk --update --no-cache add su-exec tar tzdata

WORKDIR ${WEEWX_HOME}

COPY src/entrypoint.sh src/hashes src/version.txt requirements.txt ./

RUN pip install --no-cache --requirement requirements.txt && \
    wget -O "${ARCHIVE}" "http://www.weewx.com/downloads/released_versions/${ARCHIVE}" && \
    sha256sum -c < hashes && \
    tar --extract --gunzip --directory ${WEEWX_HOME} --strip-components=1 --file "${ARCHIVE}" && \
    rm "${ARCHIVE}" && \
    chown -R weewx:weewx . && \
    mkdir /data && \
    cp weewx.conf /data
	
RUN cd /tmp && wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip && wget -O weewx-neowx.zip https://projects.neoground.com/neowx/download/latest \
    && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-neowx.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prom
	
ADD ${PWD}/src/skin.conf /home/weewx/skins/neowx/skin.conf
ADD ${PWD}/src/daily.json.tmpl /home/weewx/skins/neowx/daily.json.tmpl

VOLUME ["/data"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/data/weewx.conf"]