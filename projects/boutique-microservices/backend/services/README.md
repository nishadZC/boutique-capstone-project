# Backend Microservices

This directory contains the core backend services for the Boutique e-commerce application. The application follows a microservices architecture, breaking down functionality into loosely coupled, independently deployable Node.js services.

## 🏗️ Architecture Overview

The backend is composed of an API Gateway and several domain-specific microservices. All external traffic from the frontend is routed through the API Gateway, which forwards the requests to the appropriate internal services.

### Services

| Service | Description | Responsibilities |
| :--- | :--- | :--- |
| **Gateway** (`gateway/`) | The single entry point for all frontend requests. | - Route forwarding (Reverse Proxy) <br> - Rate limiting & CORS <br> - Aggregating metrics across services |
| **Auth** (`auth/`) | Handles user identity and access management. | - User registration and login <br> - Issuing and verifying JWT tokens <br> - Securing routes |
| **User Service** (`user-service/`) | Manages user profile data. | - Storing user information <br> - Managing addresses and preferences <br> - Account lifecycle management |
| **Product Service** (`product-service/`) | Manages the e-commerce product catalog. | - Listing and filtering products <br> - Providing product details (price, description, images) <br> - Inventory tracking |
| **Order Services** (`order-service/` & `orders/`) | Handles the core purchasing workflow. | - Shopping cart management <br> - Order placement and history <br> - Checkout and payment processing integrations |

## 🚀 Development & Communication

- **Inter-service Communication:** Services primarily communicate via synchronous HTTP/REST calls (or gRPC if configured), often mediated by the API Gateway.
- **Data Storage:** Each domain service connects to its own logical database schema (PostgreSQL) to maintain data boundaries and prevent coupling.
- **Shared Libraries:** Shared logic, types, and configurations (e.g., error handling, database connections) are abstracted into the parent `shared/` directory.

## 🛠️ Running the Services

Services can be run individually for focused development or together using `docker-compose` (from the root directory) or Kubernetes manifests.

### Environment Configuration
Each service requires specific environment variables to connect to its respective database and the Auth service. Refer to the `.env.example` in the parent `backend/` directory for the required configuration variables.
