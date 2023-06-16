
FROM mwaeckerlin/very-base
ENV CONTAINERNAME    "build/node.js"
USER root
ENV NODE_ENV         "development"
ENV PATH             "node_modules/.bin:/app/node_modules/.bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app
RUN $PKG_INSTALL git python3 g++ make npm yarn nodejs linux-headers
RUN npm i -g nexe
USER ${BUILD_USER}
RUN echo 'console.log("hello")' | nexe --build --python=$(which python3) -o /tmp/dummy
RUN rm /tmp/dummy
WORKDIR /app
