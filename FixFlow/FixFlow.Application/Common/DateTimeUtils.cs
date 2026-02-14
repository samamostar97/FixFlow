namespace FixFlow.Application.Common;

public static class DateTimeUtils
{
    public static DateTime Now => DateTime.UtcNow;
    public static DateTime Today => DateTime.UtcNow.Date;
}
