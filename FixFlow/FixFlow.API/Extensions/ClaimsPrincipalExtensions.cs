using System.Security.Claims;

namespace FixFlow.API.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static int GetRequiredUserId(this ClaimsPrincipal user)
    {
        var userIdClaim = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!int.TryParse(userIdClaim, out var userId))
        {
            throw new UnauthorizedAccessException("Korisnicka sesija nije validna.");
        }

        return userId;
    }

    public static string GetRequiredUserRole(this ClaimsPrincipal user)
    {
        var role = user.FindFirst(ClaimTypes.Role)?.Value;
        if (string.IsNullOrWhiteSpace(role))
        {
            throw new UnauthorizedAccessException("Korisnicka uloga nije dostupna.");
        }

        return role;
    }
}
