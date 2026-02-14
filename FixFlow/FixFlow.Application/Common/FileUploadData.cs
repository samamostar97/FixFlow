namespace FixFlow.Application.Common;

public class FileUploadData
{
    public string FileName { get; set; } = string.Empty;
    public long Length { get; set; }
    public Stream Content { get; set; } = Stream.Null;
}
