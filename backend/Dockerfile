FROM node:20-alpine AS runtime

WORKDIR /app
ENV NODE_ENV=production

COPY package.json pnpm-workspace.yaml ./
COPY package-lock.json ./
RUN npm ci --omit=dev

COPY backend ./backend
COPY scripts ./scripts

EXPOSE 5000
CMD ["node", "backend/server.js"]
