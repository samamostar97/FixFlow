using FixFlow.Application.Common;
using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Application.Filters;

namespace FixFlow.Application.IServices;

public interface IRepairRequestService
    : IBaseService<RepairRequestResponse, CreateRepairRequestRequest, UpdateRepairRequestRequest, RepairRequestQueryFilter>
{
    Task<RepairRequestResponse> GetByIdForUserAsync(int id, int userId, string role);
    Task<RepairRequestResponse> CreateRequestAsync(CreateRepairRequestRequest dto, int customerId);
    Task<RepairRequestResponse> UpdateRequestAsync(int id, UpdateRepairRequestRequest dto, int userId);
    Task<PagedResult<RepairRequestResponse>> GetMyRequestsAsync(RepairRequestQueryFilter filter, int userId);
    Task<PagedResult<RepairRequestResponse>> GetOpenRequestsAsync(RepairRequestQueryFilter filter);
    Task<RepairRequestResponse> CancelAsync(int id, int userId);
    Task<List<RequestImageResponse>> UploadImagesAsync(int requestId, FileUploadData[] files, int userId);
    Task DeleteImageAsync(int requestId, int imageId, int userId);
}
