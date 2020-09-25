FROM mwaeckerlin/nodejs
USER root
RUN ${PKG_INSTALL} git python g++ make npm yarn
USER ${RUN_USER}
