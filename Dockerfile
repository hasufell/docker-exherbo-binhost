FROM       hasufell/exherbo-nginx:latest
MAINTAINER Julian Ospald <hasufell@posteo.de>


COPY ./config/paludis /etc/paludis


##### PACKAGE INSTALLATION #####

# update world with our options
RUN chgrp paludisbuild /dev/tty && \
	eclectic env update && \
	source /etc/profile && \
	git clone https://github.com/hasufell/hasufell-binhost.git \
		/var/db/paludis/repositories/hasufell-binhost && \
	chown -R root:paludisbuild /var/db/paludis/repositories/hasufell-binhost && \
	cave sync && \
	cave resolve -z -1 repository/spbecker -x && \
	cave resolve -z -1 repository/virtualization -x && \
	cave resolve -z -1 repository/CleverCloud -x && \
	cave resolve -z -1 repository/philantrop -x && \
	cave update-world -s tools && \
	cave update-world -s server && \
	cave resolve -c world -x -f --permit-old-version '*/*' && \
	cave resolve -c world -x --permit-old-version '*/*' && \
	cave purge -x && \
	cave fix-linkage -x && \
	rm -rf /usr/portage/distfiles/* /srv/binhost/*

RUN eclectic config accept-all


################################

# nginx config
COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default.conf
RUN mkdir -p /var/log/nginx/log

# bashrc
COPY ./config/bashrc.addition /root/bashrc.addition
RUN cat /root/bashrc.addition >> /root/.bashrc

# paludis env
COPY ./config/90cave.env.d /etc/env.d/90cave
RUN mkdir -p /etc/paludis/tmp
RUN eclectic env update

# allow local sync again
RUN sed -i -e 's|^#sync|sync|' /etc/paludis/repositories/*.conf

