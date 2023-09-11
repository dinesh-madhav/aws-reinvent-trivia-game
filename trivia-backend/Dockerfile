FROM 339263341917.dkr.ecr.us-east-1.amazonaws.com/nike-workshop-backend-base:release@sha256:33a08e201cf2df63032d6976d247a05cb3fce4895e04ac4a60f3a5403200808f

ARG NODE_ENV=production
ARG PORT=80

ENV NODE_ENV $NODE_ENV
ENV PORT=$PORT

WORKDIR /opt/app
COPY app/package.json app/package-lock.json ./
RUN npm ci && npm prune --production && npm cache clean --force
COPY ./app /opt/app
COPY ./data /opt/data
RUN apidoc -i routes/ -o apidoc/

HEALTHCHECK --interval=30s CMD node healthcheck.js

EXPOSE $PORT

CMD [ "node", "service.js" ]