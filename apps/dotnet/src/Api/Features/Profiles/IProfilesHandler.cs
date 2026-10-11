using Realworlddotnet.Core.Dto;

namespace Realworlddotnet.Api.Features.Profiles;

public interface IProfilesHandler
{
    public Task<ProfileDto> GetAsync(string profileUsername, string? username, CancellationToken cancellationToken);

    public Task<ProfileDto> FollowProfileAsync(string profileUsername, string username,
        CancellationToken cancellationToken);

    public Task<ProfileDto> UnFollowProfileAsync(string profileUsername, string username,
        CancellationToken cancellationToken);


    // Diese Methode wird verwendet, um das Profilbild eines Benutzers zu aktualisieren, indem die Bild-URL im Profil gespeichert wird
    public Task UpdateUserImageAsync(string userId, string imageUrl, CancellationToken cancellationToken);

}
