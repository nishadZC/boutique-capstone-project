# Boutique Microservices Application

## 📖 Problem Statement

Modern web applications require high availability, rapid release cycles, and resilience against regional or cloud-provider failures. A monolithic application deployed to a single cloud provider cannot meet these strict enterprise requirements. 

**The Goal:** Modernize a microservices-based e-commerce application by migrating it to a highly scalable cloud architecture while implementing fully automated, secure, and observable **DevSecOps** pipelines.

## 🏢 Project Use Case

The Boutique application is a modern e-commerce platform designed to demonstrate the power and flexibility of a microservices architecture. It breaks down a traditional monolithic online store into independent, loosely coupled services. 

This architecture allows different teams to develop, test, deploy, and scale services independently. For example, during high-traffic events (like holiday sales), the `Orders` or `Products` services can be scaled up to handle the load without needing to scale the entire application, optimizing resource usage and cost.

## 🧩 Application Architecture

The application simulates a real-world enterprise microservices environment and consists of the following discrete services:

* **Frontend:** A responsive user interface built with React that provides a seamless shopping experience for customers.
* **API Gateway:** A Node.js service that acts as the single entry point for the frontend, routing requests to the appropriate backend microservices and handling cross-cutting concerns.
* **Auth Service:** Manages user authentication, token issuance, and authorization to secure the application.
* **Orders Service:** Handles the core e-commerce workflow, including order processing, cart management, and checkout operations.
* **Products Service:** Manages the product catalog, inventory tracking, and detailed product information.
* **Users Service:** Manages user profiles, account settings, and personal information.

## 💾 Database

The backend services are supported by a **PostgreSQL** database. This relational data store is used to persist crucial application data, ensuring data integrity for products, orders, and user information across the microservices ecosystem.
