using System.Text.RegularExpressions;

namespace FixFlow.Application.Helpers;

public static partial class SlugGenerator
{
    public static string Generate(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return string.Empty;

        var slug = input.ToLowerInvariant().Trim();
        slug = NonAlphanumericRegex().Replace(slug, "-");
        slug = MultipleDashRegex().Replace(slug, "-");
        slug = slug.Trim('-');

        return slug;
    }

    [GeneratedRegex(@"[^a-z0-9\s-]")]
    private static partial Regex NonAlphanumericRegex();

    [GeneratedRegex(@"[\s-]+")]
    private static partial Regex MultipleDashRegex();
}
