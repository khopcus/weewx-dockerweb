FROM debian:stretch

#############################
# Install Required Packages #
#############################

RUN apt-get update && apt-get full-upgrade -y \
    && apt-get install python python-pil python-imaging python-configobj python-cheetah mysql-client python-mysqldb ftp python-dev python-pip curl wget rsyslog procps gnupg -y && pip install pyephem
	
RUN apt-get install nano -y

#################
# Install WeewX #
#################

RUN cd /tmp && wget http://weewx.com/downloads/weewx-3.9.2.tar.gz && tar xvfz weewx-3.9.2.tar.gz && cd weewx-3.9.2 && ./setup.py build && ./setup.py install --no-prompt

###################################
# Download and Install Extentions #
###################################

RUN cd /tmp && wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip && wget -O weewx-neowx.zip https://projects.neoground.com/neowx/download/latest \
    && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-neowx.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt

###################################
# Download and Install Extentions #
###################################

ADD ${PWD}/src/skin.conf /home/weewx/skins/neowx/skin.conf
ADD ${PWD}/src/daily.json.tmpl /home/weewx/skins/neowx/daily.json.tmpl

RUN addgroup -g 1001 -S weewx && \
    adduser -u 1001 -S weewx -G weewx

#################
# Execute Weewx #
#################

CMD ["/home/weewx/bin/weewxd","/home/weewx/weewx.conf"]