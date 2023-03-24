
FROM mwaeckerlin/very-base
ENV CONTAINERNAME    "build/node.js"
ENV NODE_ENV         "development"
ENV PATH             "node_modules/.bin:/app/node_modules/.bin:/sbin:/usr/sbin:/bin:/usr/bin"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app
RUN $PKG_INSTALL git python3 g++ make npm yarn nodejs
USER $BUILD_USER
WORKDIR /app
