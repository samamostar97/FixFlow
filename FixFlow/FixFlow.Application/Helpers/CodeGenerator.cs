namespace FixFlow.Application.Helpers;

public static class CodeGenerator
{
    private static readonly Random Random = new();
    private const string Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    public static string Generate(string prefix, int length = 8)
    {
        var code = new char[length];
        for (var i = 0; i < length; i++)
        {
            code[i] = Chars[Random.Next(Chars.Length)];
        }

        return $"{prefix}-{new string(code)}";
    }
}
