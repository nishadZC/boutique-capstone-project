# Boutique E-Commerce Frontend

This directory contains the user interface for the Boutique microservices application. It is built as a Single Page Application (SPA) using React and communicates directly with the backend API Gateway to fetch data and perform operations.

## 🏗️ Architecture & Tech Stack

- **Framework**: React (Bootstrapped with Create React App)
- **Routing**: React Router for client-side navigation
- **State Management**: React Context / Hooks for managing cart state, user sessions, and product listings
- **Styling**: Modern, responsive CSS for a premium e-commerce look and feel
- **Containerization**: Packaged using Docker and served via NGINX in production

## 🧩 Key Features

1. **Product Catalog**: Browse the luxury fashion catalog with dynamic rendering of product details, images, and prices.
2. **Shopping Cart**: Add items to the cart, adjust quantities, and view a running total.
3. **Checkout Flow**: Simulated checkout process handling user order placement.
4. **User Authentication**: Login and registration screens (integrating with the Auth microservice).
5. **Responsive Design**: Optimized for both desktop and mobile viewing.

## 🚀 Local Development

### Prerequisites
- Node.js (v18+)
- npm or yarn

### Installation
```bash
# Navigate to the frontend directory
cd frontend

# Install dependencies
npm install
```

### Running the App
```bash
# Start the development server
npm start
```
This will launch the app in development mode at [http://localhost:3000](http://localhost:3000). The app expects the API Gateway to be running on its configured port (typically `:3001` or via the Kubernetes ingress) to fetch live data.

## 🐳 Docker Deployment

The frontend includes a `Dockerfile` that builds the optimized production React bundle and serves it using a lightweight NGINX web server. 

```bash
# Build the container
docker build -t boutique-frontend:latest .

# Run the container locally
docker run -p 3000:80 boutique-frontend:latest
```

## 🔌 API Integration

The frontend expects to communicate with the backend services via the API Gateway. In development, you may need to configure proxy rules in `package.json` or environment variables (e.g., `REACT_APP_API_URL`) to point to the correct Gateway URL.
