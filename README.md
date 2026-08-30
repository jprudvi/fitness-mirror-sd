# Fitness Mirror Project

## Overview
This is a software platform for an IoT-based Smart Fitness Mirror. It features edge AI coaching, cloud analytics, and Stripe payment integration, supporting fitness users, coaches, and platform staff. The platform includes a native mobile app (iOS: Swift/SwiftUI, Android: Kotlin/Jetpack Compose), a TypeScript/Angular PWA, and Java/Spring Boot microservices.

This repository contains architecture documentation using the C4 Model, visualized via Structurizr DSL and PlantUML diagrams. The design follows Domain-Driven Design (DDD) principles with bounded contexts and strategic context mapping.

## Project Structure
- `LICENSE.md`: MIT License, authored by IoT Solution Development Team.
- `README.md`: This file.
- `docs/`:
  - `fitness-mirror-sa.dsl`: Structurizr DSL defining the C4 Model (System Context, Container, Component levels).
  - `fitness-mirror-sa-system-context.puml`: PlantUML code for the System Context diagram.
  - `fitness-mirror-sa-container.puml`: PlantUML code for the Container diagram.
  - `fitness-mirror-sa-component-mobile-iam.puml`: PlantUML code for the Mobile App and IAM Service component diagram.
  - `fitness-mirror-sa-component-webclient.puml`: PlantUML code for the Web Client App component diagram.
  - `fitness-mirror-sa-component-subscription.puml`: PlantUML code for the Subscription Service component diagram.
  - `fitness-mirror-sa-component-edge.puml`: PlantUML code for the Fitness Local Station Edge Application component diagram.
  - `fitness-mirror-sa-component-analytics.puml`: PlantUML code for the Analytics Service component diagram.
  - `fitness-mirror-sa-component-media.puml`: PlantUML code for the Media Service component diagram.
  - `fitness-mirror-sa-component-model-training.puml`: PlantUML code for the ML Model Training Service component diagram.
  - `user-stories.md`: User stories and acceptance criteria for platform features.

## Architecture Highlights
- **Authors**: IoT Solution Development Team.
- **Design Patterns**: Domain-Driven Design (Core, Supporting, Commodity, and Generic contexts), Anti-Corruption Layers (ACL), Transactional Outbox (Edge), and Event-Driven Architecture.
- **Actors**: Visitor, Fitness User, Fitness Coach, Technical Support, R&D Team, Platform Owner, CRM Staff.
- **Infrastructure**:
  - API Gateway: Centralized routing, authentication, and security handler.
  - Message Broker: Asynchronous event propagation via RabbitMQ.
  - Cloud Storage: Data Lake (S3), Media Storage (S3), and CDN (CloudFront).
  - Model Registry: Versioned ML model management via MLflow.
- **Microservices**:
  - IAM (Commodity): User identity and access management.
  - Performance & Trends (Core): High-frequency sensor data and fitness progression.
  - Subscription (Supporting): Billing and Stripe integration.
  - Analytics (Generic): Strategic business insights and reporting.
  - Media (Supporting): Video transcoding and metadata management.
- **Polyglot Persistence**:
  - Time-Series: InfluxDB (Performance, Trends).
  - Relational: PostgreSQL (IAM, Analytics), Oracle (Subscription).
  - Edge: SQLite (Edge, Mobile), Fitness Local Station File System.

## Usage
### Structurizr DSL
1. Open `docs/fitness-mirror-sa.dsl` in Structurizr Playground ([https://playground.structurizr.com/](https://playground.structurizr.com/)).
2. Paste the DSL into the default workspace and press `Run`.
3. View diagrams: SystemContext, ContainerView, and specific Component views.

### PlantUML Diagrams
1. Open one of the `.puml` files in `docs/` in a PlantUML editor (https://www.plantuml.com/plantuml).
2. Render each diagram independently.
3. For local rendering, ensure the C4-PlantUML library is accessible via the `!include` statements.

## License
This project is licensed under the MIT License. See `LICENSE.md` for details.

## Authors
- **IoT Solution Development Team**
