FROM node:22-alpine3.21 AS build

WORKDIR /src/app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build


FROM node:22-alpine3.21 AS development

WORKDIR /src/app

COPY --from=build /src/app/dist ./dist
COPY --from=build /src/app/package*.json ./

RUN npm ci --omit=dev


FROM node:22-alpine3.21 AS production

WORKDIR /src/app

COPY --from=build /src/app/package*.json ./
COPY --from=build /src/app/dist ./dist
COPY --from=development /src/app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "run", "start:prod"]