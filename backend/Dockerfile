FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force

FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app
# RDS CA bundle so the TLS connection to MySQL is verified
ADD --chmod=0444 https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem /app/rds-ca.pem
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:3000/healthz || exit 1
CMD ["node", "src/server.js"]
