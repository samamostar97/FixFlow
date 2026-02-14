using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;

namespace FixFlow.Application.IServices;

public interface IUserService
{
    Task<UserResponse> GetProfileAsync(int userId);
    Task<UserResponse> UpdateProfileAsync(int userId, UpdateProfileRequest request);
}
