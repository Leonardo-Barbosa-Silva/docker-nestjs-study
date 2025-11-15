# ----------------------------------------- Stage 1: Build
FROM node:22-alpine3.21 AS build

WORKDIR /src/app

# Só o que é necessário pra instalar dependências
COPY package*.json ./

# Instala todas as deps (incluindo dev) para buildar
RUN npm ci

# Copia todo o resto do código da aplicação
COPY . .

# Gera os artefatos de produção (ex: dist, Nest, TS, etc)
RUN npm run build


# ----------------------------------------- Stage 2: Production
FROM node:22-alpine3.21 AS production

WORKDIR /src/app

ENV NODE_ENV=production

# Copia o package.json e lock
COPY --from=build /src/app/package*.json ./
# Copia o build pronto do stage 1
COPY --from=build /src/app/dist ./dist

# Instala só deps de produção
RUN npm ci --omit=dev

# (Opcional, mas recomendado) criar e usar usuário não-root
# RUN addgroup -S nodegrp && adduser -S nodeuser -G nodegrp
# USER nodeuser

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
