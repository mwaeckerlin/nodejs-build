FROM mwaeckerlin/nodejs
USER root
RUN ${PKG_INSTALL} git python g++ make
USER ${RUN_USER}
