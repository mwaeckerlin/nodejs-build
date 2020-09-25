NodeJS Build Environment
========================

Ready to build your NodeJS or React application. E.g. you could do in your Dockerfile:

```Dockerfile
FROM mwaeckerlin/nodejs-build as build
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN NODE_ENV=development npm install
ADD --chown=somebody . .
RUN NODE_ENV=production npm run build

FROM mwaeckerlin/nodejs-build as modules
ADD --chown=somebody package.json package.json
ADD --chown=somebody package-lock.json package-lock.json
RUN NODE_ENV=production npm install

FROM mwaeckerlin/nodejs
ENV CONTAINERNAME "project-name"
COPY --from=modules /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build
CMD node build/main
```
