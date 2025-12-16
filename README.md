# Introspect 1B: EKS Microservices with Dapr Pub/Sub

A demonstration project showcasing containerized microservices deployed on Amazon EKS, utilizing Dapr for pub/sub messaging with AWS SNS/SQS as the underlying broker.

## Project Overview

This project implements a simple e-commerce scenario with two microservices:

- **ProductService**: A publisher service that creates products and publishes events to a `product.new` topic.
- **OrderService**: A subscriber service that processes product creation events via declarative Dapr subscriptions.

The services communicate asynchronously through Dapr's pub/sub API, ensuring loose coupling and scalability.

## Architecture

- **Microservices**: Flask-based Python applications containerized with Docker
- **Orchestration**: Kubernetes deployments on Amazon EKS
- **Service Mesh**: Dapr sidecars for pub/sub, configuration, and observability
- **Messaging**: AWS SNS/SQS for durable, scalable event publishing
- **Storage**: In-memory JSON file storage (for demonstration)

## Key Technologies

- **Dapr**: Distributed Application Runtime for pub/sub and service communication
- **Kubernetes**: Container orchestration on EKS
- **AWS Services**: SNS/SQS for messaging, ECR for container registry
- **Python/Flask**: Microservice implementation
- **Docker**: Containerization

## How to Run the Project and Setup Infrastructure

For detailed step-by-step instructions, API documentation, and troubleshooting, refer to [SourceCode/README.md](SourceCode/README.md).

## Deliverables

The `Deliverables/` folder contains all project outputs, documentation, and artifacts generated during the development and deployment process. This includes:

- **Logs**: Application logs, Dapr sidecar logs, and deployment logs capturing the runtime behavior and event processing.
- **Screenshots**: Visual captures of key stages such as cluster setup, deployment status, service testing, and monitoring dashboards.
- **Architecture Diagram**: A detailed diagram illustrating the system architecture, including microservices, Dapr components, AWS services, and data flow.

**Highlighted: Architecture Diagram**  
The architecture diagram provides a comprehensive visual representation of the entire system. It shows the interaction between ProductService and OrderService, the role of Dapr sidecars, the AWS SNS/SQS messaging infrastructure, and the Kubernetes orchestration on EKS. This diagram is essential for understanding the high-level design and can be found at `Deliverables/architecture-diagram.png` (or similar filename).