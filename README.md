# Conduit RealWorld Platform

A full-stack implementation of the [RealWorld](https://github.com/gothinkster/realworld) publishing-platform specification. The project combines a .NET REST API, a Vue 3 web application, a Flutter mobile application, and SQLite persistence in one repository.

## What it demonstrates

- Registration, login and token-based authentication
- Profiles, articles, comments, favorites, tags and personalized feeds
- ASP.NET Core 9 endpoints with Swagger/OpenAPI documentation
- Entity Framework Core migrations and reproducible test data
- Vue 3 + TypeScript web client with Pinia and Vue Router
- Flutter/Dart mobile client with BLoC-based state management
- Markdown authoring/preview and profile/article image uploads
- Unit, end-to-end, Cypress and Flutter tests
- PlantUML architecture and workflow documentation

## Repository map

```text
apps/
  dotnet/    ASP.NET Core API, persistence and automated tests
  vue3/      Vue 3 + TypeScript web client
  flutter/   Flutter mobile client
docs/        Architecture material and original milestone documentation
```

## Team project

Built as a university team project by **Aziz Zarrouki, Rayan Brigui and Jihed Khattat**. The repository contains the final available milestone and presents the implementation as shared work rather than assigning features from the classroom repository's bot-generated history.

## Local setup

The original setup notes are preserved in [`docs/original-project-setup.md`](docs/original-project-setup.md), and the final milestone brief is preserved in [`docs/milestone-4-assignment.md`](docs/milestone-4-assignment.md).

The API reads its SQLite, CORS and JWT settings from standard ASP.NET Core configuration. To create a local signing certificate and keep its password outside Git:

```powershell
cd apps/dotnet/src/Api
dotnet dev-certs https -ep identityserver_testing.pfx -p "choose-a-local-password"
dotnet user-secrets set "Jwt:CertificatePassword" "choose-a-local-password"
dotnet run
```

The certificate, database and user-secret values are intentionally excluded from version control. Override `ConnectionStrings:Sqlite`, `Cors:AllowedOrigins`, `Jwt:Issuer`, `Jwt:Audience` or `Jwt:CertificatePath` through configuration when needed.

## Verification status

- Unit tests: **7/7 passing**, including image-signature and upload-size validation
- End-to-end backend tests: **3/3 passing**
- .NET 9 solution build: **passing with 0 warnings and 0 errors**
- Vue TypeScript check and production build: **passing**
- NuGet and npm dependency audits: **0 known vulnerabilities**
- Additional course-assignment tests depend on the original runtime and database environment and are therefore not included in the portable verification result above
- Local databases, certificates, APKs, real environment files, build output and caches are excluded from version control

The repository does not apply a blanket license to team-authored or third-party material. Existing upstream notices and licenses remain in force.
