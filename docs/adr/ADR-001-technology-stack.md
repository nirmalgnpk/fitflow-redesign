# ADR-001: Technology stack and architecture for the FitFlow redesign
- Status: Accepted
- Context: Consistent iOS/Android/web experience, AI workout plans, sensitive health data, real-time feed.
- Decision: React Native + NestJS + FastAPI (AI) + PostgreSQL/Redis + Amazon Cognito on AWS.
- Alternatives: Flutter, native Kotlin/Swift, Firebase, Go + DynamoDB.
- Consequences: One main language plus Python for AI; two runtimes to operate; AWS lock-in.
