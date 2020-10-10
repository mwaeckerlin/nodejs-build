NodeJS Build Environment
========================

Docker image to build your NodeJS or React application. E.g. you could do in your Dockerfile to build a NestJS application (`dist`) that includes a React frontend (`build`):

```Dockerfile
FROM mwaeckerlin/nodejs-build as modules
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN NODE_ENV=production npm install

FROM modules as build
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN NODE_ENV=development npm install
ADD --chown=somebody . .
RUN NODE_ENV=production npm run build

FROM mwaeckerlin/nodejs as production
ENV CONTAINERNAME "my-application"
EXPOSE 4000
COPY --from=modules /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build
COPY --from=build /app/dist /app/dist
CMD ["/usr/bin/node", "dist/main"]
```
