NodeJS Build Environment
========================

The Classic Way
---------------

Docker image to build your NodeJS or React application. E.g. you could do in your Dockerfile to build a NestJS application (`dist`) that includes a React frontend (`build`), so here's an example on how to create an optimized docker image:

```Dockerfile
# install only dependencies,
# not devDependencies for the final image
# only copy the necessary files, so a
# rebuild is rarely required and cache
# can be reused
FROM mwaeckerlin/nodejs-build as modules
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN NODE_ENV=production npm install

# install additional devDependencies and build
FROM modules as build
RUN NODE_ENV=development npm install
# import all sources only here where we need them
# .dockerignore excludes what you don't need
# such as Dockerfile or README.md, LICENSE, etc.
ADD --chown=somebody . .
RUN NODE_ENV=production npm run build

# now in final step, bring all together
# import the smaller node_modules from first step
# normally the build target is in dist or build
FROM mwaeckerlin/nodejs as production
ENV CONTAINERNAME "my-application"
EXPOSE 4000
COPY --from=modules /app/node_modules /app/node_modules
#COPY --from=build /app/build /app/build
COPY --from=build /app/dist /app/dist
CMD ["/usr/bin/node", "dist/main"]
```

Use Compiled JavaScript
-----------------------

Project [nexe](https://github.com/nexe/nexe) provides a JavaScript compiler to generate a single optimized all inclusive executable target file. So we can build the final image from scratch and copy only this target, e.g.

```Dockerfile
# only copy the necessary files, so a
# rebuild is rarely required and cache
# can be reused
FROM mwaeckerlin/nodejs-build as build
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN npm install
# import all sources only here where we need them
# .dockerignore excludes what you don't need
# such as Dockerfile or README.md, LICENSE, etc.
ADD --chown=somebody . .
RUN npm run build
# now let's compile the dist,
# if the main start file is in dist/src/main.js:
RUN nexe --build --python=$(which python3) dist/src/main.js
RUN strip  -s -R .comment -R .gnu.version --strip-unneeded app

# now build the final image from scratch
FROM mwaeckerlin/nodejs as production
ENV CONTAINERNAME "my-application"
EXPOSE 4000
COPY --from=build /app/app /app/app
CMD ["/app/app"]
```