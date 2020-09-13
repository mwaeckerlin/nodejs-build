NodeJS Build Environment
========================

Ready to build your NodeJS or React application. E.g. you could do in your Dockerfile:

```Dockerfile
FROM mwaeckerlin/nodejs-build as build
ADD --chown=somebody . .
RUN NODE_ENV=development npm install
RUN NODE_ENV=production npm run build

FROM mwaeckerlin/nodejs
ENV CONTAINERNAME "my-project"
COPY --from=build /app/build /app
```
