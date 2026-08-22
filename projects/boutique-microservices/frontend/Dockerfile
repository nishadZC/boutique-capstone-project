# Frontend Dockerfile — Multi-stage build
# Stage 1: Build React app
FROM node:20-alpine AS builder

# Patch OS vulnerabilities
RUN apk update && apk upgrade --no-cache

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production=false

# Copy source code
COPY . .

# Build the React app
# REACT_APP_API_URL is intentionally NOT set here so the app
# falls back to the relative '/api' path, which nginx proxies
# to the gateway — works for any environment without rebuilding.
RUN npm run build

# Stage 2: Serve with nginx (includes /api proxy to gateway)
FROM nginx:alpine

# Patch OS vulnerabilities
RUN apk update && apk upgrade --no-cache

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx config (handles SPA routing + /api proxy to gateway)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
