using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.OpenApi.Models;
using Realworlddotnet.Api.Features.Articles;
using Realworlddotnet.Api.Features.Profiles;
using Realworlddotnet.Api.Features.Tags;
using Realworlddotnet.Api.Features.Users;
using Realworlddotnet.Core.Repositories;
using Realworlddotnet.Api.Features.Search;

var builder = WebApplication.CreateBuilder(args);

var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
    ?? new[] { "http://localhost:5173", "http://localhost:3000" };

builder.Services.AddCors(options =>
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    })
);

// add logging
builder.Host.UseSerilog((hostBuilderContext, services, loggerConfiguration) =>
{
    loggerConfiguration.ConfigureBaseLogging("realworldDotnet");
});

// setup database connection (used for in memory SQLite).
// SQLite in memory requires an open connection during the application lifetime
#pragma warning disable S125
// to use a file based SQLite use: "Filename=../realworld.db";
// in:memory  configuration.GetConnectionString("Sqlite") ?? "Filename=:memory:";
#pragma warning restore S125
var connectionString = builder.Configuration.GetConnectionString("Sqlite") ?? "Filename=../../realworld.db";

var connection = new SqliteConnection(connectionString);
connection.DefaultTimeout = 60;
connection.Open();


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SupportNonNullableReferenceTypes();
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "realworlddotnet", Version = "v1" });
    c.AddSecurityDefinition("Bearer",
        new OpenApiSecurityScheme
        {
            In = ParameterLocation.Header,
            Description = "Please enter the token",
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            BearerFormat = "JWT",
            Scheme = "bearer"
        });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddScoped<IConduitRepository, ConduitRepository>();
builder.Services.AddScoped<IUserHandler, UserHandler>();
builder.Services.AddScoped<IArticlesHandler, ArticlesHandler>();
builder.Services.AddScoped<ITagsHandler, TagsHandler>();
builder.Services.AddScoped<IProfilesHandler, ProfilesHandler>();
builder.Services.AddScoped<ISearchHandler, SearchHandler>();

builder.Services.Configure<PasswordHasherOptions>(opt =>
    opt.CompatibilityMode = PasswordHasherCompatibilityMode.IdentityV3);
builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "Conduit.Api";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "Conduit.Clients";
var jwtCertificatePath = builder.Configuration["Jwt:CertificatePath"] ?? "identityserver_testing.pfx";
var jwtCertificatePassword = builder.Configuration["Jwt:CertificatePassword"];

if (string.IsNullOrWhiteSpace(jwtCertificatePassword))
{
    throw new InvalidOperationException(
        "Configure Jwt:CertificatePassword through user secrets or an environment variable before starting the API.");
}

var resolvedCertificatePath = Path.IsPathRooted(jwtCertificatePath)
    ? jwtCertificatePath
    : Path.Combine(builder.Environment.ContentRootPath, jwtCertificatePath);

builder.Services.AddSingleton<CertificateProvider>();
builder.Services.AddSingleton<X509Certificate2>(container =>
{
    var certificateProvider = container.GetRequiredService<CertificateProvider>();
    return certificateProvider.LoadFromFile(resolvedCertificatePath, jwtCertificatePassword);
});

builder.Services.AddSingleton<ITokenGenerator>(container =>
{
    var certificate = container.GetRequiredService<X509Certificate2>();
    return new TokenGenerator(certificate, jwtIssuer, jwtAudience);
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
builder.Services.AddAuthorization();
builder.Services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
    .Configure<X509Certificate2>((options, certificate) =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1),
            IssuerSigningKey = new RsaSecurityKey(
                certificate.GetRSAPublicKey()
                ?? throw new InvalidOperationException("The JWT certificate does not contain an RSA public key."))
        };
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = CustomOnMessageReceivedHandler.OnMessageReceived
        };
    });

// for SQLite in memory a connection is provided rather than a connection string
builder.Services.AddDbContext<ConduitContext>(options => { options.UseSqlite(connection); });

builder.Services.AddProblemDetails((Hellang.Middleware.ProblemDetails.ProblemDetailsOptions options) => { });
builder.Services.ConfigureOptions<ProblemDetailsLogging>();
builder.Services.AddCarter();

var app = builder.Build();

// Configure the HTTP request pipeline.
Log.Information("Start configuring http request pipeline");

// when using in memory SQLite ensure the tables are created
using (var scope = app.Services.CreateScope())
{
    using var context = scope.ServiceProvider.GetService<ConduitContext>();
    context?.Database.EnsureCreated();
}

app.UseSerilogRequestLogging(options =>
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        diagnosticContext.Set("UserId", httpContext.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "")
);


app.UsePathBase("/api");

// Hier wird konfiguriert, dass statische Dateien (Bilder) vom Server ausgeliefert werden können
app.UseStaticFiles(new StaticFileOptions
{
    // Beim Ausliefern jeder statischen Datei wird die folgende Anweisung ausgeführt
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Cache-Control", "no-cache, no-store, must-revalidate"); // Cache wird vollständig deaktiviert

        ctx.Context.Response.Headers.Append("Pragma", "no-cache"); // Auch der alte Pragma-Header wird gesetzt, um das Caching zu verhindern
        
        ctx.Context.Response.Headers.Append("Expires", "0"); // Die Datei wird als sofort abgelaufen markiert
    }
});

app.UseRouting();
app.UseProblemDetails();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.UseSwagger();
app.UseSwaggerUI(c => {
    c.SwaggerEndpoint("/api/swagger/v1/swagger.json", "realworlddotnet v1");
});
app.MapCarter();


try
{
    Log.Information("Starting web host");
    app.Run();
    return 0;
}
catch (Exception ex)
{
    Log.Fatal(ex, "Host terminated unexpectedly");
    return 1;
}
finally
{
    connection.Close();
    Log.CloseAndFlush();
}

