using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Exceptions;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;

namespace FixFlow.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly IRepository<User> _repository;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IRepository<User> repository,
        IConfiguration configuration,
        ILogger<AuthService> logger)
    {
        _repository = repository;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        if (request.Role == UserRole.Admin)
            throw new ForbiddenException("Registracija admin korisnika nije dozvoljena.");

        var emailExists = await _repository.AsQueryable()
            .AnyAsync(u => u.Email == request.Email.ToLower().Trim());

        if (emailExists)
            throw new ConflictException("Korisnik sa ovim emailom vec postoji.");

        var user = new User
        {
            Email = request.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Phone = request.Phone?.Trim(),
            Role = request.Role
        };

        await _repository.AddAsync(user);

        _logger.LogInformation("User {UserId} registered with role {Role}", user.Id, user.Role);

        return new AuthResponse
        {
            Token = GenerateJwtToken(user),
            User = user.Adapt<UserResponse>()
        };
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await _repository.AsQueryable()
            .FirstOrDefaultAsync(u => u.Email == request.Email.ToLower().Trim());

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Pogresan email ili lozinka.");

        _logger.LogInformation("User {UserId} logged in", user.Id);

        return new AuthResponse
        {
            Token = GenerateJwtToken(user),
            User = user.Adapt<UserResponse>()
        };
    }

    public Task<AuthResponse> RefreshAsync(string token)
    {
        throw new NotSupportedException("Osvjezavanje sesije trenutno nije podrzano. Prijavite se ponovo.");
    }

    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("Jwt");
        var secretKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings["Secret"]!));

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
            new(ClaimTypes.Email, user.Email),
            new(ClaimTypes.Role, user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTimeUtils.Now.AddMinutes(double.Parse(jwtSettings["ExpirationInMinutes"]!)),
            signingCredentials: new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}