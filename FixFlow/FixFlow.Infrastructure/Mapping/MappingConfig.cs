using FixFlow.Application.DTOs.Request;
using FixFlow.Application.DTOs.Response;
using FixFlow.Core.Entities;
using Mapster;

namespace FixFlow.Infrastructure.Mapping;

public static class MappingConfig
{
    public static void RegisterMappings()
    {
        TypeAdapterConfig.GlobalSettings.Default
            .IgnoreNullValues(true);

        // User
        TypeAdapterConfig<User, UserResponse>.NewConfig();
        TypeAdapterConfig<UpdateProfileRequest, User>.NewConfig()
            .IgnoreNullValues(true);

        // RepairCategory
        TypeAdapterConfig<CreateRepairCategoryRequest, RepairCategory>.NewConfig();
        TypeAdapterConfig<UpdateRepairCategoryRequest, RepairCategory>.NewConfig()
            .IgnoreNullValues(true);
        TypeAdapterConfig<RepairCategory, RepairCategoryResponse>.NewConfig();

        // TechnicianProfile — Mapster auto-flattens User.FirstName → UserFirstName
        TypeAdapterConfig<CreateTechnicianProfileRequest, TechnicianProfile>.NewConfig();
        TypeAdapterConfig<UpdateTechnicianProfileRequest, TechnicianProfile>.NewConfig()
            .IgnoreNullValues(true);
        TypeAdapterConfig<TechnicianProfile, TechnicianProfileResponse>.NewConfig();

        // RepairRequest — auto-flattens Category.Name, Customer.FirstName/LastName/Email/Phone
        TypeAdapterConfig<CreateRepairRequestRequest, RepairRequest>.NewConfig()
            .Ignore(dest => dest.CustomerId)
            .Ignore(dest => dest.Status);
        TypeAdapterConfig<UpdateRepairRequestRequest, RepairRequest>.NewConfig()
            .IgnoreNullValues(true);
        TypeAdapterConfig<RepairRequest, RepairRequestResponse>.NewConfig();

        // RequestImage
        TypeAdapterConfig<RequestImage, RequestImageResponse>.NewConfig();

        // Offer — auto-flattens RepairRequest.Category.Name, Technician.FirstName/LastName
        TypeAdapterConfig<CreateOfferRequest, Offer>.NewConfig()
            .Ignore(dest => dest.TechnicianId)
            .Ignore(dest => dest.Status);
        TypeAdapterConfig<UpdateOfferRequest, Offer>.NewConfig()
            .IgnoreNullValues(true);
        TypeAdapterConfig<Offer, OfferResponse>.NewConfig()
            .Map(dest => dest.RepairRequestCategoryName, src => src.RepairRequest.Category.Name);

        // Booking — custom flattening for nested navigation properties
        TypeAdapterConfig<Booking, BookingResponse>.NewConfig()
            .Map(dest => dest.RepairRequestDescription, src => src.RepairRequest.Description)
            .Map(dest => dest.RepairRequestCategoryName, src => src.RepairRequest.Category.Name)
            .Map(dest => dest.OfferPrice, src => src.Offer.Price)
            .Map(dest => dest.OfferEstimatedDays, src => src.Offer.EstimatedDays)
            .Map(dest => dest.OfferServiceType, src => src.Offer.ServiceType)
            .Map(dest => dest.CustomerPhone, src => src.Customer.Phone)
            .Map(dest => dest.TechnicianPhone, src => src.Technician.Phone);

        // JobStatusHistory — auto-flattens ChangedBy.FirstName/LastName
        TypeAdapterConfig<JobStatusHistory, JobStatusHistoryResponse>.NewConfig();
    }
}
