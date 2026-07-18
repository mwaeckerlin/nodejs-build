NodeJS Build Environment
========================

Docker image to build NodeJS applications. **Not for deployments** — use this image only in build stages of a multi-stage Dockerfile; the final stage of a production image inherits from [mwaeckerlin/nodejs](https://github.com/mwaeckerlin/nodejs) (or [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch) for compiled binaries), as shown in the examples below.

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
ADD --chown=${BUILD_USER} package.json package.json
ADD --chown=${BUILD_USER} package-lock.json package-lock.json
RUN NODE_ENV=production npm install

# install additional devDependencies and build
FROM modules as build
RUN NODE_ENV=development npm install
# import all sources only here where we need them
# .dockerignore excludes what you don't need
# such as Dockerfile or README.md, LICENSE, etc.
ADD --chown=${BUILD_USER} . .
RUN NODE_ENV=production npm run build

# now in final step, bring all together
# import the smaller node_modules from first step
# normally the build target is in dist or build
FROM mwaeckerlin/nodejs as production
EXPOSE 4000
COPY --from=build /app/dist /app/dist
COPY --from=modules /app/node_modules node_modules
```

The default `CMD` fits to the output of [mwaeckerlin/schematics](https://github.com/mwaeckerlin/schematics)).

See also: [mwaeckerlin/nodejs](https://github.com/mwaeckerlin/nodejs)


Use Compiled JavaScript
-----------------------

Project [nexe](https://github.com/nexe/nexe) provides a JavaScript compiler to generate a single optimized all inclusive executable target file. So we can build the final image from scratch and copy only this target, e.g.

```Dockerfile
# only copy the necessary files, so a
# rebuild is rarely required and cache
# can be reused
FROM mwaeckerlin/nodejs-build as build
ADD --chown=${BUILD_USER} package.json package.json
ADD --chown=${BUILD_USER} package-lock.json package-lock.json
RUN npm install
# import all sources only here where we need them
# .dockerignore excludes what you don't need
# such as Dockerfile or README.md, LICENSE, etc.
ADD --chown=${BUILD_USER} . .
RUN npm run build
# now let's compile the dist,
# if the main start file is in dist/src/main.js:
RUN nexe --build --python=$(which python3) -o app dist/src/main.js

# now build the final image from scratch
FROM mwaeckerlin/nodejs as production
ENV CONTAINERNAME "my-application"
EXPOSE 4000
COPY --from=build /app/app /app/app
CMD ["/app/app", "--trace-uncaught"]
```
