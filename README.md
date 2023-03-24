NodeJS Build Environment
========================

Docker image to build your NodeJS or React application. E.g. you could do in your Dockerfile to build a NestJS application (`dist`) that includes a React frontend (`build`):

```Dockerfile
FROM mwaeckerlin/nodejs-build AS build
COPY --chown=${BUILD_USER} package.json package-lock.json ./
RUN npm install
COPY --chown=${BUILD_USER} . .
RUN npm run build

FROM mwaeckerlin/nodejs-build AS node-modules
COPY --chown=${BUILD_USER} package.json package-lock.json ./
RUN npm install

FROM mwaeckerlin/nodejs as production
EXPOSE 4000
COPY --from=build /app/dist /app/dist
COPY --from=node-modules /app/node_modules node_modules
```

The default `CMD` fits to the output of [mwaeckerlin/schematics](https://github.com/mwaeckerlin/schematics)).

See also: [mwaeckerlin/nodejs](https://github.com/mwaeckerlin/nodejs)