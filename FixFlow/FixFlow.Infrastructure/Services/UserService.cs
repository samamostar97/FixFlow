using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using Mapster;

namespace FixFlow.Infrastructure.Services;

public class UserService : IUserService
{
    private readonly IRepository<User> _repository;

    public UserService(IRepository<User> repository)
    {
        _repository = repository;
    }

    public async Task<UserResponse> GetProfileAsync(int userId)
    {
        var user = await _repository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen.");

        return user.Adapt<UserResponse>();
    }

    public async Task<UserResponse> UpdateProfileAsync(int userId, UpdateProfileRequest request)
    {
        var user = await _repository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen.");

        request.Adapt(user);
        await _repository.UpdateAsync(user);

        return user.Adapt<UserResponse>();
    }
}
