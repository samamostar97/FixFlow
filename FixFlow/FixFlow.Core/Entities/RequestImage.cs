namespace FixFlow.Core.Entities;

public class RequestImage : BaseEntity
{
    public int RepairRequestId { get; set; }
    public RepairRequest RepairRequest { get; set; } = null!;

    public string ImagePath { get; set; } = string.Empty;
    public string OriginalFileName { get; set; } = string.Empty;
    public long FileSize { get; set; }
}
