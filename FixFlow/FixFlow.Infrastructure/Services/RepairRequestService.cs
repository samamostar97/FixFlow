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
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace FixFlow.Infrastructure.Services;

public class RepairRequestService
    : BaseService<RepairRequest, RepairRequestResponse, CreateRepairRequestRequest,
        UpdateRepairRequestRequest, RepairRequestQueryFilter>,
      IRepairRequestService
{
    private readonly IRepository<RepairCategory> _categoryRepository;
    private readonly IRepository<RequestImage> _imageRepository;
    private readonly ILogger<RepairRequestService> _logger;
    private readonly string _storagePath;
    private readonly long _maxFileSize;
    private readonly string[] _allowedExtensions;

    public RepairRequestService(
        IRepository<RepairRequest> repository,
        IRepository<RepairCategory> categoryRepository,
        IRepository<RequestImage> imageRepository,
        IConfiguration configuration,
        ILogger<RepairRequestService> logger) : base(repository)
    {
        _categoryRepository = categoryRepository;
        _imageRepository = imageRepository;
        _logger = logger;
        _storagePath = configuration["FileUpload:StoragePath"] ?? "wwwroot/uploads";
        _maxFileSize = long.Parse(configuration["FileUpload:MaxFileSizeBytes"] ?? "5242880");
        _allowedExtensions = configuration.GetSection("FileUpload:AllowedImageExtensions")
            .Get<string[]>() ?? new[] { ".jpg", ".jpeg", ".png", ".webp" };
    }

    protected override IQueryable<RepairRequest> ApplyFilter(
        IQueryable<RepairRequest> query, RepairRequestQueryFilter filter)
    {
        return query
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                r => r.Description.ToLower().Contains(filter.Search!.ToLower())
                    || (r.Address != null && r.Address.ToLower().Contains(filter.Search!.ToLower()))
                    || r.Customer.FirstName.ToLower().Contains(filter.Search!.ToLower())
                    || r.Customer.LastName.ToLower().Contains(filter.Search!.ToLower()))
            .WhereIf(filter.Status.HasValue, r => r.Status == filter.Status)
            .WhereIf(filter.CategoryId.HasValue, r => r.CategoryId == filter.CategoryId)
            .WhereIf(filter.PreferenceType.HasValue, r => r.PreferenceType == filter.PreferenceType)
            .WhereIf(filter.CustomerId.HasValue, r => r.CustomerId == filter.CustomerId)
            .OrderByDescending(r => r.CreatedAt);
    }

    public override async Task<RepairRequestResponse> GetByIdAsync(int id)
    {
        var entity = await _repository.AsQueryable()
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .FirstOrDefaultAsync(r => r.Id == id)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        return entity.Adapt<RepairRequestResponse>();
    }

    public async Task<RepairRequestResponse> GetByIdForUserAsync(int id, int userId, string role)
    {
        var entity = await _repository.AsQueryable()
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .Include(r => r.Offers)
            .Include(r => r.Booking)
            .FirstOrDefaultAsync(r => r.Id == id)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            return entity.Adapt<RepairRequestResponse>();
        }

        if (string.Equals(role, "Customer", StringComparison.OrdinalIgnoreCase))
        {
            if (entity.CustomerId != userId)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovaj zahtjev.");
            }

            return entity.Adapt<RepairRequestResponse>();
        }

        if (string.Equals(role, "Technician", StringComparison.OrdinalIgnoreCase))
        {
            var canView = entity.Status == RepairRequestStatus.Open
                          || entity.Status == RepairRequestStatus.Offered
                          || entity.Offers.Any(o => o.TechnicianId == userId)
                          || entity.Booking?.TechnicianId == userId;

            if (!canView)
            {
                throw new ForbiddenException("Nemate pravo vidjeti ovaj zahtjev.");
            }

            return entity.Adapt<RepairRequestResponse>();
        }

        throw new ForbiddenException("Nemate pravo vidjeti ovaj zahtjev.");
    }

    // Custom create - sets CustomerId from JWT via controller
    public async Task<RepairRequestResponse> CreateRequestAsync(CreateRepairRequestRequest dto, int customerId)
    {
        _ = await _categoryRepository.GetByIdAsync(dto.CategoryId)
            ?? throw new KeyNotFoundException("Kategorija nije pronadena.");

        var entity = dto.Adapt<RepairRequest>();
        entity.CustomerId = customerId;
        entity.Status = RepairRequestStatus.Open;
        entity.Description = dto.Description.Trim();
        entity.Address = dto.Address?.Trim();

        await _repository.AddAsync(entity);

        _logger.LogInformation("RepairRequest {RequestId} created by customer {CustomerId}", entity.Id, customerId);

        return await GetByIdAsync(entity.Id);
    }

    // Custom update - validates ownership and status
    public async Task<RepairRequestResponse> UpdateRequestAsync(int id, UpdateRepairRequestRequest dto, int userId)
    {
        var entity = await _repository.AsQueryable()
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .FirstOrDefaultAsync(r => r.Id == id)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (entity.CustomerId != userId)
            throw new ForbiddenException("Nemate pravo mijenjati ovaj zahtjev.");

        if (entity.Status != RepairRequestStatus.Open)
            throw new InvalidOperationException("Zahtjev se moze mijenjati samo dok je u statusu Otvoren.");

        if (dto.CategoryId.HasValue)
        {
            _ = await _categoryRepository.GetByIdAsync(dto.CategoryId.Value)
                ?? throw new KeyNotFoundException("Kategorija nije pronadena.");
        }

        dto.Adapt(entity);
        if (dto.Description != null) entity.Description = dto.Description.Trim();
        if (dto.Address != null) entity.Address = dto.Address.Trim();

        await _repository.UpdateAsync(entity);

        return entity.Adapt<RepairRequestResponse>();
    }

    public async Task<PagedResult<RepairRequestResponse>> GetMyRequestsAsync(
        RepairRequestQueryFilter filter, int userId)
    {
        filter.CustomerId = userId;
        return await GetAllAsync(filter);
    }

    public async Task<PagedResult<RepairRequestResponse>> GetOpenRequestsAsync(
        RepairRequestQueryFilter filter)
    {
        var query = _repository.AsQueryable()
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .Where(r => r.Status == RepairRequestStatus.Open || r.Status == RepairRequestStatus.Offered)
            .WhereIf(!string.IsNullOrWhiteSpace(filter.Search),
                r => r.Description.ToLower().Contains(filter.Search!.ToLower())
                    || (r.Address != null && r.Address.ToLower().Contains(filter.Search!.ToLower())))
            .WhereIf(filter.CategoryId.HasValue, r => r.CategoryId == filter.CategoryId)
            .WhereIf(filter.PreferenceType.HasValue, r => r.PreferenceType == filter.PreferenceType)
            .OrderByDescending(r => r.CreatedAt);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new PagedResult<RepairRequestResponse>
        {
            Items = items.Adapt<List<RepairRequestResponse>>(),
            TotalCount = totalCount,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize
        };
    }

    public async Task<RepairRequestResponse> CancelAsync(int id, int userId)
    {
        var entity = await _repository.AsQueryable()
            .Include(r => r.Category)
            .Include(r => r.Customer)
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .FirstOrDefaultAsync(r => r.Id == id)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (entity.CustomerId != userId)
            throw new ForbiddenException("Nemate pravo otkazati ovaj zahtjev.");

        if (entity.Status != RepairRequestStatus.Open && entity.Status != RepairRequestStatus.Offered)
            throw new InvalidOperationException("Zahtjev se moze otkazati samo dok je Otvoren ili ima ponude.");

        entity.Status = RepairRequestStatus.Cancelled;
        await _repository.UpdateAsync(entity);

        _logger.LogInformation("RepairRequest {RequestId} cancelled by customer {CustomerId}", id, userId);

        return entity.Adapt<RepairRequestResponse>();
    }

    public async Task<List<RequestImageResponse>> UploadImagesAsync(int requestId, FileUploadData[] files, int userId)
    {
        var request = await _repository.AsQueryable()
            .Include(r => r.Images.Where(i => !i.IsDeleted))
            .FirstOrDefaultAsync(r => r.Id == requestId)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (request.CustomerId != userId)
            throw new ForbiddenException("Nemate pravo dodavati slike na ovaj zahtjev.");

        var existingCount = request.Images.Count;
        if (existingCount + files.Length > 5)
            throw new InvalidOperationException($"Maksimalno 5 slika po zahtjevu. Trenutno imate {existingCount}, pokusavate dodati {files.Length}.");

        var uploadedImages = new List<RequestImage>();
        var uploadDir = Path.Combine(_storagePath, "repair-requests");
        Directory.CreateDirectory(uploadDir);

        foreach (var file in files)
        {
            ValidateFile(file);

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var safeFileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadDir, safeFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.Content.CopyToAsync(stream);
            }

            var image = new RequestImage
            {
                RepairRequestId = requestId,
                ImagePath = $"/uploads/repair-requests/{safeFileName}",
                OriginalFileName = file.FileName,
                FileSize = file.Length
            };

            await _imageRepository.AddAsync(image);
            uploadedImages.Add(image);
        }

        _logger.LogInformation("{Count} images uploaded for RepairRequest {RequestId}", files.Length, requestId);

        return uploadedImages.Adapt<List<RequestImageResponse>>();
    }

    public async Task DeleteImageAsync(int requestId, int imageId, int userId)
    {
        var request = await _repository.GetByIdAsync(requestId)
            ?? throw new KeyNotFoundException("Zahtjev za popravku nije pronaden.");

        if (request.CustomerId != userId)
            throw new ForbiddenException("Nemate pravo brisati slike sa ovog zahtjeva.");

        var image = await _imageRepository.AsQueryable()
            .FirstOrDefaultAsync(i => i.Id == imageId && i.RepairRequestId == requestId)
            ?? throw new KeyNotFoundException("Slika nije pronadena.");

        await _imageRepository.DeleteAsync(image);

        _logger.LogInformation("Image {ImageId} soft-deleted from RepairRequest {RequestId}", imageId, requestId);
    }

    private void ValidateFile(FileUploadData file)
    {
        if (file.Length == 0)
            throw new InvalidOperationException("Fajl je prazan.");

        if (file.Length > _maxFileSize)
            throw new InvalidOperationException($"Fajl '{file.FileName}' prelazi maksimalnu velicinu od {_maxFileSize / 1024 / 1024}MB.");

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_allowedExtensions.Contains(extension))
            throw new InvalidOperationException($"Ekstenzija '{extension}' nije dozvoljena. Dozvoljene: {string.Join(", ", _allowedExtensions)}.");

        ValidateMimeType(file, extension);
    }

    private static void ValidateMimeType(FileUploadData file, string extension)
    {
        var position = file.Content.Position;
        using var reader = new BinaryReader(file.Content, System.Text.Encoding.UTF8, leaveOpen: true);
        var headerBytes = reader.ReadBytes(8);
        file.Content.Position = position;

        var isValid = extension switch
        {
            ".jpg" or ".jpeg" => headerBytes.Length >= 2 && headerBytes[0] == 0xFF && headerBytes[1] == 0xD8,
            ".png" => headerBytes.Length >= 4 && headerBytes[0] == 0x89 && headerBytes[1] == 0x50
                      && headerBytes[2] == 0x4E && headerBytes[3] == 0x47,
            ".webp" => headerBytes.Length >= 4 && headerBytes[0] == 0x52 && headerBytes[1] == 0x49
                       && headerBytes[2] == 0x46 && headerBytes[3] == 0x46,
            _ => false
        };

        if (!isValid)
            throw new InvalidOperationException($"Sadrzaj fajla ne odgovara ekstenziji '{extension}'.");
    }
}