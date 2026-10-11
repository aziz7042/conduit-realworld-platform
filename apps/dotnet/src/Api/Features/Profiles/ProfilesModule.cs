using Microsoft.AspNetCore.Mvc;
using Realworlddotnet.Api.Features;
using Realworlddotnet.Core.Dto;

namespace Realworlddotnet.Api.Features.Profiles;

public class ProfilesModule : ICarterModule
{
    public void AddRoutes(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("profiles")
            .RequireAuthorization()
            .WithTags("Profile")
            .IncludeInOpenApi();

        group.MapGet("{username}",
                async Task<Ok<ProfilesEnvelope<ProfileDto>>>
                    (string username, IProfilesHandler profilesHandler, ClaimsPrincipal claimsPrincipal) =>
                {
                    var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                    var result = await profilesHandler.GetAsync(username, user, new CancellationToken());
                    return TypedResults.Ok(new ProfilesEnvelope<ProfileDto>(result));
                })
            .WithName("GetProfile");

        group.MapPost("{followUsername}/follow",
                async Task<Ok<ProfilesEnvelope<ProfileDto>>>
                    (string followUsername, IProfilesHandler profilesHandler, ClaimsPrincipal claimsPrincipal) =>
                {
                    var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                    var result =
                        await profilesHandler.FollowProfileAsync(followUsername, user!, new CancellationToken());
                    return TypedResults.Ok(new ProfilesEnvelope<ProfileDto>(result));
                })
            .WithName("FollowProfile");

        group.MapDelete("{followUsername}/follow",
                async Task<Ok<ProfilesEnvelope<ProfileDto>>>
                    (string followUsername, IProfilesHandler profilesHandler, ClaimsPrincipal claimsPrincipal) =>
                {
                    var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                    var result =
                        await profilesHandler.UnFollowProfileAsync(followUsername, user!, new CancellationToken());
                    return TypedResults.Ok(new ProfilesEnvelope<ProfileDto>(result));
                })
            .WithName("UnfollowProfile");



        // Diese Route ermöglicht es einem angemeldeten Benutzer, ein Profilbild hochzuladen
        group.MapPost("image",
                async Task<IResult>
                    ([FromForm] IFormFile file, ClaimsPrincipal claimsPrincipal, IProfilesHandler profilesHandler,
                        HttpContext context, IWebHostEnvironment environment) =>
                {
                    // Der aktuell angemeldete Benutzer wird aus dem Authentifizierungs-Token ausgelesen
                    var username = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);

                    // Falls der Benutzer nicht authentifiziert ist, wird 401 Unauthorized zurückgegeben
                    if (string.IsNullOrEmpty(username))
                        throw new ProblemDetailsException(401, "Nicht autorisiert.");

                    var extension = await ImageUploadValidator.ValidateAndGetExtensionAsync(
                        file,
                        context.RequestAborted);

                    // Der Speicherpfad für die hochgeladenen Dateien wird festgelegt
                    var webRoot = environment.WebRootPath ?? Path.Combine(environment.ContentRootPath, "wwwroot");
                    var uploadsPath = Path.Combine(webRoot, "uploads");

                    // Falls das Upload-Verzeichnis noch nicht existiert, wird es automatisch erstellt
                    if (!Directory.Exists(uploadsPath))
                        Directory.CreateDirectory(uploadsPath);

                    // A server-generated name prevents user input from becoming part of a filesystem path.
                    var fileName = $"{Guid.NewGuid():N}{extension}";

                    // Der vollständige Speicherpfad der Datei wird erstellt
                    var filePath = Path.Combine(uploadsPath, fileName);

                    // Die hochgeladene Datei wird im Speicherpfad gespeichert
                    await using var stream = new FileStream(
                        filePath, FileMode.CreateNew, FileAccess.Write, FileShare.None, 81920, useAsync: true);
                    await file.CopyToAsync(stream, context.RequestAborted);

                    // Die URL zur gespeicherten Datei wird generiert, damit das Frontend das Bild später abrufen kann
                    var imageUrl =
                        $"{context.Request.Scheme}://{context.Request.Host}{context.Request.PathBase}/uploads/{fileName}";

                    // Die neue Bild-URL wird im Benutzerprofil gespeichert
                    await profilesHandler.UpdateUserImageAsync(username, imageUrl, context.RequestAborted);

                    // Am Ende wird die Bild-URL als Bestätigung an das Frontend zurückgegeben
                    return TypedResults.Ok(new { imageUrl });
                })
            .WithName("UploadProfileImage");


    }
}
