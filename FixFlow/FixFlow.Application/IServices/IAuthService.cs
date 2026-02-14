using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;

namespace FixFlow.Application.IServices;

public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest request);
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse> RefreshAsync(string token);
}
