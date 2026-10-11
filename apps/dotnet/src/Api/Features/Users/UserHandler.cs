using Microsoft.AspNetCore.Identity;
using Realworlddotnet.Core.Dto;
using Realworlddotnet.Core.Repositories;

namespace Realworlddotnet.Api.Features.Users;

public class UserHandler : IUserHandler
{
    private readonly IConduitRepository _repository;
    private readonly ITokenGenerator _tokenGenerator;
    private readonly IPasswordHasher<User> _passwordHasher;
    public UserHandler(IConduitRepository repository, ITokenGenerator tokenGenerator, IPasswordHasher<User> passwordHasher)
    {
        _repository = repository;
        _tokenGenerator = tokenGenerator;
        _passwordHasher = passwordHasher;
    }

    public async Task<UserDto> CreateAsync(NewUserDto newUser, CancellationToken cancellationToken)
    {
        var user = new User(newUser);
        if (user.Password != null)
        {
            user.Password = this._passwordHasher.HashPassword(user, user.Password);    
        }
        await _repository.AddUserAsync(user);
        await _repository.SaveChangesAsync(cancellationToken);
        var token = _tokenGenerator.CreateToken(user.Username);
        return new UserDto(user.Username, user.Email, token, user.Bio, user.Image);
    }

    public async Task<UserDto> UpdateAsync(
        string username, UpdatedUserDto updatedUser, CancellationToken cancellationToken)
    {
        var user = await _repository.GetUserByUsernameAsync(username, cancellationToken);
        if (updatedUser.OldPassword != null || updatedUser.NewPassword != null) 
        {
            if (updatedUser.OldPassword == null)
            {
                throw new ProblemDetailsException(422, "Incorrect Credentials");
            }
            // validate old password
            var verificationResult = await DoPasswordVerification(updatedUser.OldPassword, cancellationToken, user);

            if (verificationResult == PasswordVerificationResult.Failed)
            {
                throw new ProblemDetailsException(422, "Incorrect Credentials");
            }
            if (updatedUser.NewPassword != null)
            {
                user.UpdateUser(updatedUser);
                user.Password = this._passwordHasher.HashPassword(user, updatedUser.NewPassword);    
            }
            else
            {
                throw new ProblemDetailsException(422, "Invalid Password (empty)");
            }
        }
        else
        {
            user.UpdateUser(updatedUser);    
        }
        await _repository.SaveChangesAsync(cancellationToken);
        var token = _tokenGenerator.CreateToken(user.Username);
        return new UserDto(user.Username, user.Email, token, user.Bio, user.Image);
    }

    public async Task<UserDto> LoginAsync(LoginUserDto login, CancellationToken cancellationToken)
    {
        var user = await _repository.GetUserByEmailAsync(login.Email);

        if (user == null)
        {
            throw new ProblemDetailsException(422, "Incorrect Email");
        }
        
        var verificationResult = await DoPasswordVerification(login.Password, cancellationToken, user);
        if (verificationResult == PasswordVerificationResult.Failed)
        {
            throw new ProblemDetailsException(422, "Incorrect Credentials");
        }

        var token = _tokenGenerator.CreateToken(user.Username);
        return new UserDto(user.Username, user.Email, token, user.Bio, user.Image);
    }

    private async Task<PasswordVerificationResult> DoPasswordVerification(
        string loginPassword,
        CancellationToken cancellationToken,
        User user)
    {
        var verificationResult = _passwordHasher.VerifyHashedPassword(user, user.Password, loginPassword);
        if (verificationResult == PasswordVerificationResult.SuccessRehashNeeded)
        {
            user.Password = _passwordHasher.HashPassword(user, loginPassword);
            await _repository.SaveChangesAsync(cancellationToken);
            return PasswordVerificationResult.Success;
        }

        return verificationResult;
    }

    public async Task<UserDto> GetAsync(string username, CancellationToken cancellationToken)
    {
        var user = await _repository.GetUserByUsernameAsync(username, cancellationToken);
        var token = _tokenGenerator.CreateToken(user.Username);
        return new UserDto(user.Username, user.Email, token, user.Bio, user.Image);
    }
}
