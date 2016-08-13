FROM       hasufell/exherbo:latest
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
	cave resolve -z -1 repository/net -x && \
	cave resolve -z -1 repository/hasufell -x && \
	cave resolve -z -1 repository/spbecker -x && \
	cave resolve -z -1 repository/virtualization -x && \
	cave resolve -z -1 repository/unavailable-unofficial -x && \
	cave resolve -z -1 repository/philantrop -x && \
	cave update-world www-servers/nginx && \
	cave update-world -s tools && \
	cave update-world -s server && \
	cave resolve -c world -x -f --permit-old-version '*/*' && \
	cave resolve -c world -x --permit-old-version '*/*' && \
	cave fix-linkage -x && \
	rm -rf /usr/portage/distfiles/* /srv/binhost/*

RUN eclectic config accept-all


################################

COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default.conf

COPY ./config/bashrc.addition /root/bashrc.addition
RUN cat /root/bashrc.addition >> /root/.bashrc

COPY ./config/90cave.env.d /etc/env.d/90cave
RUN mkdir -p /etc/paludis/tmp
RUN eclectic env update

RUN mkdir -p /var/log/nginx/log

# allow local sync again
RUN sed -i -e 's|^#sync|sync|' /etc/paludis/repositories/*.conf

