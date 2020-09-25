FROM mwaeckerlin/nodejs
MAINTAINER mwaeckerlin

ENV CONTAINERNAME    "build/node.js"
USER root
RUN ${PKG_INSTALL} git python g++ make npm yarn
USER ${RUN_USER}
