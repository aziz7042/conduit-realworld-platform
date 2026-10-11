using Realworlddotnet.Core.Dto;
using Realworlddotnet.Core.Repositories;

namespace Realworlddotnet.Api.Features.Profiles;

public class ProfilesHandler : IProfilesHandler
{
    private readonly IConduitRepository _repository;

    public ProfilesHandler(IConduitRepository repository)
    {
        _repository = repository;
    }

    public async Task<ProfileDto> GetAsync(string profileUsername, string? username,
        CancellationToken cancellationToken)
    {
        var profileUser = await _repository.GetUserByUsernameAsync(profileUsername, cancellationToken);

        if (profileUser is null)
        {
            throw new ProblemDetailsException(422, "Profile not found");
        }

        var isFollowing = false;

        if (username is not null)
        {
            isFollowing = await _repository.IsFollowingAsync(profileUsername, username, cancellationToken);
        }

        return new ProfileDto(profileUser.Username, profileUser.Bio, profileUser.Image, isFollowing);
    }

    public async Task<ProfileDto> FollowProfileAsync(string profileUsername, string username,
        CancellationToken cancellationToken)
    {
        var profileUser = await _repository.GetUserByUsernameAsync(profileUsername, cancellationToken);

        if (profileUser is null)
            throw new ProblemDetailsException(422, "Profile not found");
        

        _repository.Follow(profileUsername, username);
        await _repository.SaveChangesAsync(cancellationToken);

        return new ProfileDto(profileUser.Username, profileUser.Bio, profileUser.Email, true);
    }

    public async Task<ProfileDto> UnFollowProfileAsync(string profileUsername, string username,
        CancellationToken cancellationToken)
    {
        var profileUser = await _repository.GetUserByUsernameAsync(profileUsername, cancellationToken);

        if (profileUser is null)
        {
            throw new ProblemDetailsException(422, "Profile not found");
        }

        _repository.UnFollow(profileUsername, username);
        await _repository.SaveChangesAsync(cancellationToken);

        return new ProfileDto(profileUser.Username, profileUser.Bio, profileUser.Email, false);
    }


    // Die Methode UpdateUserImageAsync wird verwendet, um das Profilbild eines Benutzers zu aktualisieren
    public async Task UpdateUserImageAsync(string userId, string imageUrl, CancellationToken cancellationToken)
    {
        // Zuerst wird der Benutzer anhand der userId aus der Datenbank geladen
        var user = await _repository.GetUserByUsernameAsync(userId, cancellationToken);

        // dann wird es geprüft, ob der Benutzer existiert, Falls nicht, wird eine Fehlermeldung mit dem Statuscode 404 ausgelöst
        if (user == null)
            throw new ProblemDetailsException(404, "User not found");

        // Wenn der Benutzer existiert, wird das neue Profilbild in das Benutzerobjekt geschrieben
        user.Image = imageUrl;

        // Die Änderungen am Benutzerprofil werden dauerhaft in der Datenbank gespeichert
        await _repository.SaveChangesAsync(cancellationToken);
    }
}
