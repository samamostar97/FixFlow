using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface ITechnicianProfileService
    : IBaseService<TechnicianProfileResponse, CreateTechnicianProfileRequest, UpdateTechnicianProfileRequest, TechnicianProfileQueryFilter>
{
    Task<TechnicianProfileResponse> GetMyProfileAsync(int userId);
    Task<TechnicianProfileResponse> UpdateMyProfileAsync(int userId, UpdateTechnicianProfileRequest request);
    Task<TechnicianProfileResponse> VerifyAsync(int id);
}
