using Asemane.Web.Models;
namespace Asemane.Web.Services;
public static class MediaRoles
{
    public static IEnumerable<ImageRole> ForKind(ContentKind kind) => kind switch
    {
        ContentKind.Project => new[] { ImageRole.HomeFirst, ImageRole.HomeSecond, ImageRole.ProjectCard, ImageRole.ProjectBanner, ImageRole.ProjectGallery },
        ContentKind.Article => new[] { ImageRole.ArticleSquare, ImageRole.ArticleBanner },
        ContentKind.Team => new[] { ImageRole.TeamSquare, ImageRole.TeamLandscape },
        ContentKind.Page => new[] { ImageRole.PageBanner },
        _ => Array.Empty<ImageRole>()
    };
    public static bool IsAllowed(ContentKind kind, ImageRole role) => ForKind(kind).Contains(role);
    public static bool IsSingle(ImageRole role) => role is >= ImageRole.HomeFirst and <= ImageRole.ProjectBanner or >= ImageRole.TeamSquare and <= ImageRole.TeamLandscape or ImageRole.ArticleSquare or ImageRole.ArticleBanner or ImageRole.PageBanner;
}
