using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography.X509Certificates;
using Microsoft.IdentityModel.Tokens;
using Realworlddotnet.Infrastructure.Utils.Interfaces;
using JwtRegisteredClaimNames = Microsoft.IdentityModel.JsonWebTokens.JwtRegisteredClaimNames;

namespace Realworlddotnet.Infrastructure.Utils;

public class TokenGenerator : ITokenGenerator
{
    private readonly string _audience;
    private readonly string _issuer;
    private readonly RsaSecurityKey _rsaSecurityKey;

    public TokenGenerator(X509Certificate2 certificate, string issuer, string audience)
    {
        var privateKey = certificate.GetRSAPrivateKey()
            ?? throw new ArgumentException("The JWT certificate does not contain an RSA private key.", nameof(certificate));

        _rsaSecurityKey = new RsaSecurityKey(privateKey);
        _issuer = issuer;
        _audience = audience;
    }

    public string CreateToken(string username)
    {
        var claims = new[] { new Claim(JwtRegisteredClaimNames.Sub, username) };

        var handler = new JwtSecurityTokenHandler();
        var token = new JwtSecurityToken(
            _issuer,
            _audience,
            claims,
            DateTime.UtcNow.AddMilliseconds(-30),
            DateTime.UtcNow.AddMinutes(60),
            new SigningCredentials(_rsaSecurityKey, SecurityAlgorithms.RsaSha256));

        return handler.WriteToken(token);
    }
}
