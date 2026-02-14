using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Exceptions;
using FixFlow.Application.Filters;
using FixFlow.Application.Helpers;
using FixFlow.Application.IRepositories;
using FixFlow.Application.IServices;
using FixFlow.Core.Entities;
using FixFlow.Core.Enums;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FixFlow.Infrastructure.Services;

public class TechnicianProfileService
    : BaseService<TechnicianProfile, TechnicianProfileResponse, CreateTechnicianProfileRequest,
        UpdateTechnicianProfileRequest, TechnicianProfileQueryFilter>,
      ITechnicianProfileService
{
    private readonly IRepository<User> _userRepository;
    private readonly ILogger<TechnicianProfileService> _logger;

    public TechnicianProfileService(
        IRepository<TechnicianProfile> repository,
        IRepository<User> userRepository,
        ILogger<TechnicianProfileService> logger) : base(repository)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    protected override IQueryable<TechnicianProfile> ApplyFilter(
        IQueryable<TechnicianProfile> query, TechnicianProfileQueryFilter filter)
    {
        return query
            .Include(t => t.User)
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                t => t.User.FirstName.ToLower().Contains(filter.Search!.ToLower())
                    || t.User.LastName.ToLower().Contains(filter.Search!.ToLower())
                    || t.User.Email.ToLower().Contains(filter.Search!.ToLower())
                    || (t.Specialties != null && t.Specialties.ToLower().Contains(filter.Search!.ToLower())))
            .WhereIf(filter.IsVerified.HasValue, t => t.IsVerified == filter.IsVerified)
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Zone),
                t => t.Zone != null && t.Zone.ToLower().Contains(filter.Zone!.ToLower()))
            .OrderByDescending(t => t.CreatedAt);
    }

    public override async Task<TechnicianProfileResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.AsQueryable()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new KeyNotFoundException("Profil majstora nije pronađen.");

        return entity.Adapt<TechnicianProfileResponse>();
    }

    protected override async Task ValidateCreateAsync(TechnicianProfile entity, CreateTechnicianProfileRequest dto)
    {
        var user = await _userRepository.GetByIdAsync(dto.UserId)
            ?? throw new KeyNotFoundException("Korisnik nije pronađen.");

        if (user.Role != UserRole.Technician)
            throw new InvalidOperationException("Samo korisnik sa ulogom Majstor može imati profil majstora.");

        var exists = await _repository.AsQueryable()
            .AnyAsync(t => t.UserId == dto.UserId);

        if (exists)
            throw new ConflictException("Korisnik već ima profil majstora.");
    }

    protected override Task PrepareCreateAsync(TechnicianProfile entity, CreateTechnicianProfileRequest dto)
    {
        entity.IsVerified = false;
        entity.Bio = dto.Bio?.Trim();
        entity.Specialties = dto.Specialties?.Trim();
        entity.WorkingHours = dto.WorkingHours?.Trim();
        entity.Zone = dto.Zone?.Trim();
        return Task.CompletedTask;
    }

    public async Task<TechnicianProfileResponse> GetMyProfileAsync(int userId)
    {
        var profile = await _repository.AsQueryable()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.UserId == userId)
            ?? throw new KeyNotFoundException("Nemate kreiran profil majstora.");

        return profile.Adapt<TechnicianProfileResponse>();
    }

    public async Task<TechnicianProfileResponse> UpdateMyProfileAsync(int userId, UpdateTechnicianProfileRequest request)
    {
        var profile = await _repository.AsQueryable()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.UserId == userId)
            ?? throw new KeyNotFoundException("Nemate kreiran profil majstora.");

        request.Adapt(profile);
        await _repository.UpdateAsync(profile);

        _logger.LogInformation("Technician {UserId} updated their profile {ProfileId}", userId, profile.Id);

        return profile.Adapt<TechnicianProfileResponse>();
    }

    public async Task<TechnicianProfileResponse> VerifyAsync(int id)
    {
        var profile = await _repository.AsQueryable()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new KeyNotFoundException("Profil majstora nije pronađen.");

        if (profile.IsVerified)
            throw new InvalidOperationException("Profil majstora je već verificiran.");

        profile.IsVerified = true;
        await _repository.UpdateAsync(profile);

        _logger.LogInformation("TechnicianProfile {ProfileId} verified by admin", profile.Id);

        return profile.Adapt<TechnicianProfileResponse>();
    }

    public override async Task<List<LookupResponse>> GetLookupAsync()
    {
        return await _repository.AsQueryable()
            .Include(t => t.User)
            .Where(t => t.IsVerified)
            .OrderBy(t => t.User.FirstName)
            .Select(t => new LookupResponse
            {
                Id = t.Id,
                Name = t.User.FirstName + " " + t.User.LastName
            })
            .ToListAsync();
    }
}
