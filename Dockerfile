
FROM mwaeckerlin/build
ENV CONTAINERNAME "build/node.js"
USER root
RUN $PKG_INSTALL upx
RUN npm i -g nexe
USER ${BUILD_USER}
RUN echo 'console.log("hello")' | nexe --build --python=$(which python3) -o /tmp/dummy
RUN rm /tmp/dummy
RUN strip -s -R .comment -R .gnu.version --strip-unneeded ~/.nexe/*/out/Release/node
RUN upx --lzma ~/.nexe/*/out/Release/node
