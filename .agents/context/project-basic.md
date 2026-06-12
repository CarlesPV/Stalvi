# Project Overview (Depends on the project)

**Name:** E-Commerce Inventory Manager
**Objective:** A high-performance microservice to handle real-time inventory updates and stock reservations for an e-commerce platform.
**Tech Stack:** Node.js, Express, TypeScript, PostgreSQL, Redis.

## Core Rules
- Performance is critical. All database queries must be optimized.
- The system must be idempotent. Repeating a request should not deduct stock twice.