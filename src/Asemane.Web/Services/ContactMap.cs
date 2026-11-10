using Asemane.Web.Models;
namespace Asemane.Web.Services;
public static class ContactMap
{
    public const string OriginalEmbedUrl = "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d433.4534275670794!2d52.46754196395525!3d29.643562671668445!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3fb211782f169fc3%3A0xd2a2338b1b2f4542!2sAsmane%20Architectural%20Studio!5e0!3m2!1sen!2s!4v1791317058835!5m2!1sen!2s";
    public static bool IsAllowed(string? value) => Uri.TryCreate(value,UriKind.Absolute,out var uri)
        && uri.Scheme == "https" && uri.IsDefaultPort && string.IsNullOrEmpty(uri.UserInfo)
        && (uri.Host == "www.google.com" || uri.Host == "maps.google.com")
        && (uri.AbsolutePath == "/maps" || uri.AbsolutePath.StartsWith("/maps/",StringComparison.Ordinal));
    public static string GetUrl(SiteSettings settings, IConfiguration config)
    {
        if (IsAllowed(settings.MapEmbedUrl)) return settings.MapEmbedUrl;
        if (settings.Latitude.HasValue && settings.Longitude.HasValue)
            return FormattableString.Invariant($"https://www.google.com/maps?q={settings.Latitude},{settings.Longitude}&output=embed");
        var legacy = config["Site:MapEmbedUrl"];
        return IsAllowed(legacy) ? legacy! : OriginalEmbedUrl;
    }
}
