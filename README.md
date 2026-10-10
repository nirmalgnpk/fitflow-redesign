cat > README.md <<'EOF'
# FitFlow Redesign

FitFlow Redesign is a personalized fitness and wellness platform designed to provide users with AI-generated workout plans, nutrition tracking, progress tracking, and social sharing across iOS, Android and web.

## Project Overview

The system consists of:

- React Native (Expo) mobile application and React / Next.js web application
- NestJS backend API
- FastAPI AI recommendation service
- PostgreSQL database
- Redis caching layer
- Real-time communication layer (Socket.IO)
- Authentication and authorization with Amazon Cognito

## Main Features

- User registration and authentication
- Quick workout logging
- AI-generated personalized workout plans
- Progress tracking with charts, streaks and milestones
- Nutrition tracking with calorie and macro summary
- Community feed with posts, likes and comments
- Real-time updates

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | React Native (Expo, TypeScript) / React (Next.js) |
| Backend | NestJS |
| AI Service | FastAPI / Python |
| Database | PostgreSQL (pgvector) |
| Cache | Redis |
| Real-time | WebSocket / Socket.IO |
| Authentication | Amazon Cognito (JWT) |
| Storage | Amazon S3 |
| Hosting | AWS ECS Fargate |
| CI/CD | GitHub Actions |
| API Documentation | Swagger / OpenAPI |
| Version Control | Git / GitHub |

## Project Structure

```text
fitflow-redesign/
├── frontend/
│   ├── mobile/
│   └── web/
├── backend/
├── ai-service/
├── infra/
├── docs/
│   ├── adr/
│   ├── tech-stack-summary.md
│   ├── comparison-matrix.md
│   └── architecture.png
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── LICENSE
└── README.md
```
EOF
