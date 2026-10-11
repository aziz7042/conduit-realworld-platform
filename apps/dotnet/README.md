# Conduit API · ASP.NET Core 9

The backend for this repository's RealWorld implementation. It provides the article, profile, comment, favorite, tag and authentication endpoints consumed by the Vue and Flutter clients.

## Stack

- .NET 9 and ASP.NET Core Minimal APIs
- Carter modules for endpoint organization
- Entity Framework Core with SQLite
- JWT authentication
- Swagger/OpenAPI and Problem Details responses

## Run locally

From `apps/dotnet/src/Api`, create a local development certificate and keep its password in user secrets:

```powershell
dotnet dev-certs https -ep identityserver_testing.pfx -p "choose-a-local-password"
dotnet user-secrets set "Jwt:CertificatePassword" "choose-a-local-password"
dotnet run
```

Build and test the solution from `apps/dotnet`:

```powershell
dotnet build
dotnet test tst/Unit.Tests/Unit.Tests.csproj --no-build
dotnet test tst/E2e.Tests/E2e.Tests.csproj --no-build
```

Local certificates, database files and user-secret values are excluded from Git.

`tst/Assignment.Tests` belongs to the original course harness. Some checks require the classroom API/database environment and are therefore not part of the portable commands above.

## Credits

The API implements the [RealWorld specification](https://github.com/gothinkster/realworld) and adapts ideas from Erik van der Valk's [Clean Architecture RealWorld implementation](https://github.com/Erikvdv/realworlddotnet). This university team project converted the architecture to Minimal APIs and integrated it with the repository's web and mobile clients. Upstream notices and licenses remain in force.
