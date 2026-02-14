namespace FixFlow.Application.DTOs.Response;

public class RequestImageResponse
{
    public int Id { get; set; }
    public string ImagePath { get; set; } = string.Empty;
    public string OriginalFileName { get; set; } = string.Empty;
    public long FileSize { get; set; }
}
