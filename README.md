cat > README.md <<'EOF'
# FitFlow Redesign

Redesign of the FitFlow fitness app with AI-powered workout plans,
progress tracking, nutrition logging and a social community feed.
Course: IT3060 Human Computer Interaction, SLIIT (Lab Sheet 5).

## Tech Stack
- Frontend: React Native (Expo, TypeScript) and React / Next.js web
- Backend: NestJS (TypeScript) with WebSocket gateway
- AI service: Python FastAPI
- Data: PostgreSQL (pgvector), Redis, Amazon S3
- Authentication: Amazon Cognito
- Hosting / CI: AWS ECS Fargate, GitHub Actions

## Repository Structure
- frontend/   - mobile and web clients
- backend/    - core API and real-time gateway
- ai-service/ - AI microservice
- infra/      - deployment and infrastructure files
- docs/       - tech stack summary, comparison matrix, architecture, ADRs

## Documentation
- docs/tech-stack-summary.md
- docs/comparison-matrix.md
- docs/architecture.png
- docs/adr/ADR-001-technology-stack.md

## Getting Started
Setup instructions will be added as each service is implemented.
EOF