using System.Text;
using System.Text.RegularExpressions;
using Asemane.Web.Models;
namespace Asemane.Web.Services;
public static class Slugs
{
    public static string Normalize(string value)
    {
        var normalized = value.Trim().Normalize(NormalizationForm.FormKC).ToLowerInvariant();
        return Regex.Replace(Regex.Replace(normalized, @"[^\p{L}\p{N}-]+", "-"), "-+", "-").Trim('-');
    }
    public static string Segment(ContentKind kind) => kind switch
    {
        ContentKind.Project => "projects", ContentKind.Article => "journal", ContentKind.Team => "team", _ => "pages"
    };
    public static string Path(ContentKind kind, string culture, string slug) => kind == ContentKind.Page && slug is "about" or "contact" ? $"/{culture}/{slug}" : $"/{culture}/{Segment(kind)}/{Uri.EscapeDataString(slug)}";
}
