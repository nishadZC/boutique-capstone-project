# Order Service Dockerfile (JavaScript service)
FROM node:20-slim

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

# Copy source code
COPY . .

# Create non-root user
RUN groupadd -r -g 1001 nodejs
RUN useradd -r -u 1001 -g nodejs nodejs

USER nodejs

EXPOSE 3004

CMD ["node", "src/server.js"]
