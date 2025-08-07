# Bus Booking App Implementation Guide for AI Developer

This document serves as a comprehensive guide for an AI developer tasked with implementing the 'Tease App' bus booking system. It consolidates architectural decisions, recommended tech stack, and detailed workflow considerations, providing a step-by-step approach to development.

## 1. Project Overview and Core Principles

The 'Tease App' is a modern bus booking application designed for efficiency, scalability, and an intuitive user experience. It leverages a microservices architecture, event-driven patterns, and real-time communication to provide a seamless booking experience. The core principles guiding this implementation are:

*   **Modularity and Decoupling:** Services should be independently deployable and loosely coupled.
*   **Scalability:** The system must be able to handle increasing user loads and data volumes.
*   **Resilience:** The application should be fault-tolerant and able to recover gracefully from failures.
*   **Real-time Responsiveness:** User interfaces should update instantly to reflect changes in seat availability and booking status.
*   **Security:** Robust security measures must be implemented at all layers of the application.
*   **Observability:** Comprehensive monitoring, logging, and tracing are essential for operational visibility.
*   **User-Centric Design:** The user experience should be intuitive, efficient, and delightful.

## 2. Architectural Overview

The application will be built upon a microservices architecture, with each service responsible for a specific business capability. Communication between services will primarily be asynchronous via a message broker, with synchronous communication for direct requests where immediate responses are critical.

### 2.1 Core Microservices

*   **Auth Service:** Manages user authentication (login, registration, OTP, user sessions) and authorization (JWT-based role validation).
*   **Seat Manager Service:** Handles seat locking, availability, and timers. It maintains the state of each seat (`available`, `locked`, `held_by_others`, `booked`, `expired`) and emits events on state changes.
*   **Booking Service:** Manages passenger data, validates booking ownership, and orchestrates the booking process.
*   **Payment Service:** Integrates with payment gateways, manages payment countdowns, and processes payment confirmations via webhooks.
*   **Notification Service:** Sends transactional notifications (e.g., tickets via SMS/email, booking confirmations).
*   **Realtime Gateway Service:** Manages WebSocket/Socket.IO connections to update all connected clients in real-time with seat status changes and other relevant events.
*   **Admin Dashboard Service:** Provides an interface for agency staff to manage trips, verify tickets, and access operational data.
*   **Timer Service (TAAS):** A centralized service responsible for managing all time-sensitive operations (seat hold expiry, info submission expiry, payment expiry) and emitting events upon timer expiration.

### 2.2 Communication Patterns

*   **Asynchronous Communication:** Primarily via a **message broker (Apache Kafka or Redis Pub/Sub)** for event-driven interactions (e.g., `seat:locked`, `payment:timeout`). This ensures loose coupling and scalability.
*   **Synchronous Communication:** RESTful APIs or gRPC for direct requests between services where immediate responses are required (e.g., Auth Service validating a token for another service).
*   **Real-time UI Updates:** **WebSockets/Socket.IO** for broadcasting real-time updates from the backend to connected frontend clients.

### 2.3 Data Management

*   **Database per Service:** Each microservice will ideally own its data store (e.g., PostgreSQL for relational data, Redis for caching/session data). This promotes autonomy and prevents tight coupling.
*   **Eventual Consistency:** For distributed transactions, eventual consistency will be achieved through event-driven patterns and potentially the Saga pattern.

## 3. Recommended Tech Stack

### 3.1 Backend

*   **Language:** Python (with FastAPI)
*   **Database:** PostgreSQL
*   **ORM:** SQLAlchemy
*   **Data Validation:** Pydantic
*   **Authentication:** JWT (JSON Web Tokens)
*   **Message Broker:** Apache Kafka (for durability and high throughput) or Redis Pub/Sub (for low-latency real-time events)
*   **Caching:** Redis

### 3.2 Frontend

*   **Framework:** React
*   **State Management:** Redux or Zustand
*   **Real-time Communication:** WebSocket API with Socket.IO
*   **Styling:** Tailwind CSS or Styled Components

### 3.3 Deployment & Infrastructure

*   **Containerization:** Docker
*   **Orchestration:** Kubernetes
*   **Cloud Provider:** (Choice of AWS, Google Cloud, Azure - leveraging managed services)
*   **CI/CD:** GitLab CI/CD, GitHub Actions, or Jenkins
*   **Monitoring & Logging:** Prometheus, Grafana, ELK Stack (Elasticsearch, Logstash, Kibana) or Grafana Loki, Jaeger/Zipkin

### 3.4 AI/ML Components

*   **NLP/Voice AI:** OpenAI APIs (Whisper, GPT) or Google Cloud AI Platform (Dialogflow, Text-to-Speech)
*   **ML Frameworks (for custom models):** TensorFlow or PyTorch

## 4. Step-by-Step Implementation Guide

This section outlines the implementation phases, focusing on a modular and iterative approach. Each step should be implemented, tested, and deployed independently where possible.

### Phase 1: Foundational Services and Core User Flow (MVP)

**Objective:** Establish the basic microservices architecture and implement the core trip booking flow (App Launch, Choose Trip, Choose Seats, Passenger Info, Payment).

1.  **Project Setup:**
    *   Initialize a new project repository.
    *   Set up Docker for containerization of all services.
    *   Configure basic CI/CD pipelines for automated builds and testing.

2.  **Auth Service:**
    *   Implement user registration, login, and session management (JWT-based).
    *   Define user roles (e.g., `user`, `admin`, `agent`).
    *   Expose secure API endpoints for authentication.

3.  **Seat Manager Service:**
    *   Design the database schema for seats, including `seat_id`, `status` (`available`, `locked`, `held_by_others`, `booked`, `expired`), `locked_by_user_id`, `lock_expiry_time`.
    *   Implement API endpoints for:
        *   Retrieving seat availability for a given bus/trip.
        *   Locking a seat (setting `status` to `locked`, `locked_by_user_id`, `lock_expiry_time`).
        *   Releasing a seat (setting `status` to `available`).
    *   Integrate with a message broker to publish `seat:locked`, `seat:unlocked`, `seat:booked`, `seat:expired` events.

4.  **Booking Service:**
    *   Design the database schema for bookings, passengers, and tickets.
    *   Implement API endpoints for:
        *   Creating a new booking (initial state).
        *   Updating passenger information for a booking.
        *   Validating booking ownership.
    *   Subscribe to `seat:locked` and `seat:expired` events from the Seat Manager to update booking status internally.

5.  **Payment Service:**
    *   Integrate with a chosen payment gateway (e.g., Tranzak, Stripe, PayPal).
    *   Implement API endpoints for:
        *   Initiating a payment session (generating `payment_session_id`).
        *   Handling payment callbacks/webhooks from the payment gateway to confirm payment success or failure.
    *   Publish `payment:succeeded` and `payment:failed` events to the message broker.

6.  **Timer Service (TAAS):**
    *   Implement a centralized service to manage timers for seat holds, passenger info submission, and payment.
    *   Store timer data (e.g., `entity_id`, `entity_type`, `expiry_time`, `callback_event`).
    *   Periodically check for expired timers and publish corresponding events (e.g., `booking:timeout`, `payment:timeout`) to the message broker.

7.  **Realtime Gateway Service:**
    *   Set up a WebSocket/Socket.IO server.
    *   Subscribe to `seat:locked`, `seat:unlocked`, `seat:booked`, `seat:expired` events from the message broker.
    *   Broadcast these events to all connected frontend clients to ensure real-time UI synchronization.

8.  **Frontend (React) - Core Booking Flow:**
    *   Develop the App Launch screen with navigation.
    *   Implement the 


Choose Trip flow (departure, destination, date selection, trip listing).
    *   Implement the Choose Seats flow with visual representation of seats and the 5-minute countdown timer. Ensure real-time updates from the Realtime Gateway.
    *   Develop the Passenger Info entry forms with autofill capabilities and the continuing 5-minute countdown.
    *   Implement the Payment Window, displaying fare summary, extra luggage note, and integrating with the Payment Service for payment initiation and confirmation. Display the 10-minute countdown.
    *   Ensure robust error handling and user feedback at each step.

### Phase 2: Enhancements and Advanced Features

**Objective:** Integrate AI capabilities, enhance user experience, and build operational tools.

1.  **AI Assistant Integration:**
    *   Integrate with OpenAI APIs (Whisper for Speech-to-Text, GPT for NLP/NLG) or Google Cloud AI Platform (Dialogflow, Text-to-Speech).
    *   Develop a dedicated AI Assistant microservice that orchestrates calls to the NLP/Voice AI services and interacts with other backend services (e.g., Booking Service for fare estimates, Trip Dashboard for viewing trips).
    *   Implement the AI Assistant UI component in the frontend, accessible from all screens.

2.  **Trip Dashboard ("My Trips") Implementation:**
    *   Develop the frontend UI for Active, Completed, and Cancelled trips.
    *   Implement features to view digital tickets (QR Code, Ticket Code, Passenger info, Trip details).
    *   Implement functionality for cancelling tickets (integrating with Booking Service and Payment Service for refunds, if applicable) and contacting support.
    *   (Future) Implement ticket transfer functionality.

3.  **Admin Dashboard (Staff App) - Boarding Module:**
    *   Develop a separate frontend application (or a module within the main app) for agency staff.
    *   Implement QR code scanning functionality (using device camera) to verify tickets.
    *   Implement manual ticket code entry as a fallback.
    *   Integrate with the Booking Service to mark tickets as "Boarded" and update seat status to "USED" in the Seat Manager.
    *   Ensure real-time manifest updates for agents.

4.  **Extra Luggage Flow Enhancements:**
    *   Implement UI in the booking flow to notify users about extra luggage charges.
    *   (Future) Develop functionality for pre-booking and pre-payment of extra luggage, integrating with the Payment Service.
    *   Enhance the Admin Dashboard for agents to add extra luggage charges and generate payment QR/USSD links.

### Phase 3: Smart AI Expansion and Optimization

**Objective:** Implement advanced AI features and continuous optimization.

1.  **Full Voice Booking:**
    *   Extend the AI Assistant to handle the entire booking process via voice commands, from trip selection to payment.
    *   Requires sophisticated conversational AI and integration with all core booking services.

2.  **AI Ticket Transfer Assistant:**
    *   Develop an AI-powered assistant to guide users through the process of transferring tickets, handling policy checks and necessary data updates.

3.  **AI Luggage Estimator (Vision):**
    *   Integrate computer vision models to analyze photos of luggage and estimate charges. This would require training a custom ML model.

4.  **Smart Search & Recommender:**
    *   Implement machine learning models for personalized trip recommendations (e.g., cheapest trips, popular destinations).
    *   Develop advanced search capabilities using AI for natural language queries.

5.  **Predictive Analytics and BI:**
    *   Set up data pipelines to collect and process data from all services into a data warehouse.
    *   Develop ML models for demand forecasting, dynamic pricing, and fraud detection.
    *   Integrate with BI tools (e.g., Tableau, Power BI) for reporting and dashboards.

## 5. Best Practices and Implementation Guidelines for AI Developer

*   **Modular Development:** Develop each microservice and frontend component independently. Use clear API contracts for inter-service communication.
*   **Test-Driven Development (TDD):** Write tests before writing code. This ensures code quality, reduces bugs, and facilitates refactoring.
*   **Code Reviews:** Conduct regular code reviews to maintain code quality, share knowledge, and catch potential issues early.
*   **Version Control:** Use Git for version control. Implement a branching strategy (e.g., GitFlow, GitHub Flow) for collaborative development.
*   **Documentation:** Document APIs, database schemas, and complex logic. Keep documentation up-to-date.
*   **Error Handling and Logging:** Implement comprehensive error handling and centralized logging across all services. Use structured logging for easier analysis.
*   **Security First:** Design and implement with security in mind from the outset. Follow secure coding practices, implement robust authentication and authorization, and encrypt sensitive data.
*   **Performance Optimization:** Continuously monitor and optimize performance. Use caching where appropriate and optimize database queries.
*   **Scalability Considerations:** Design services to be stateless where possible and leverage horizontal scaling for high-traffic components.
*   **Observability:** Implement metrics, tracing, and alerting for all services to gain deep insights into system health and performance.
*   **Iterative Development:** Adopt an agile methodology, delivering features in small, iterative cycles. Gather user feedback frequently and incorporate it into subsequent iterations.
*   **Containerization and Orchestration:** Leverage Docker and Kubernetes for consistent deployment environments and automated management.
*   **Cloud-Native Principles:** Design for cloud environments, utilizing managed services where they provide significant operational benefits.

## 6. Frontend Design Aesthetic

For the frontend, the user prefers a luxurious, futuristic, and highly dynamic design aesthetic. This includes:

*   **Landing Page:** Inspired by `visily.ai/ai-ui-design-generator/`, featuring animations, a 3D Earth view (facing Africa) with zoom-in animations to specific regions, and dynamic pop-ups highlighting data points.
*   **Login/Registration Page:** Futuristic and non-static background with a 'tech poetic' feel, including 'Sign in with Google/GitHub' options.
*   **Dashboards and all other pages:** Impressive and 'packed with info,' similar to `prium.github.io/falcon/v3.23.0/index.html` (especially its analytics page), with significant and relevant charts and numbers. This aesthetic should be applied consistently across the entire application.
*   **Product Catalog (e.g., bus listings):** Design aesthetic similar to Jumia and Konga for clear and efficient display of options.

## 7. Payment Gateway Integration (Tranzak Example)

When integrating payment gateways, a backend-to-frontend flow is recommended, where the backend acts as an intermediary for all API calls to the payment provider. Using Tranzak as an example:

1.  **User Initiates Payment (Frontend):** The frontend sends a request to the backend with payment details.
2.  **Backend Processes Payment Request (Backend):** The backend obtains an authentication token from Tranzak using `TRANZAK_API_KEY` and `TRANZAK_API_SECRET`, then makes a POST request to Tranzak's `/collection/v1/create` endpoint with payment details. Tranzak returns a `paymentAuthUrl` to the backend.
3.  **Redirect User for Payment (Frontend):** The backend sends the `paymentAuthUrl` back to the frontend, which then redirects the user's browser to this URL to complete the transaction.
4.  **Payment Confirmation and Webhooks (Backend):** After the user completes payment, Tranzak redirects the user back to the `returnUrl` and sends a webhook notification to the `callbackUrl`. The backend should process this webhook to update order status and handle post-payment logic.

**Important:** `TRANZAK_API_KEY`, `TRANZAK_API_SECRET`, and `TRANZAK_BASE_URL` should only be used on the backend server and never exposed to the frontend.

## 8. Hosting Architecture (Render Preference)

When recommending hosting solutions, prioritize Render with separate deployments for backend, frontend, and database. This aligns with microservices principles and provides dedicated resources for each component.

## 9. Backend Development Best Practices

When developing backend applications using FastAPI, PostgreSQL, SQLAlchemy, Pydantic, and JWT authentication, adhere to these practices:

*   **RESTful Architecture:** Follow RESTful principles for API design.
*   **Separation of Concerns:** Separate routers, services, and schemas for clear code organization.
*   **Input/Output Validation:** Use Pydantic for robust input and output validation.
*   **Database Operations:** Use SQLAlchemy for all database interactions.
*   **JSON Responses:** Ensure every route returns proper JSON responses with appropriate HTTP status codes.
*   **JWT-based Role Validation:** Implement JWT-based role validation for authentication and authorization.
*   **User Role Checks:** Always check user roles before allowing actions to enforce access control.

This `context.md` file provides a detailed roadmap for the AI developer to build the Tease App, ensuring adherence to modern software development practices and a focus on scalability, efficiency, and user experience. The AI developer should refer to this document throughout the development process, using it as a primary source of truth for architectural decisions and implementation details.

