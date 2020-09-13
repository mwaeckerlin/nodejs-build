FROM mwaeckerlin/nodejs-build
ENV NODE_ENV "production"
USER root
RUN ${PKG_INSTALL} git python g++ make
USER ${RUN_USER}
