using Asemane.Web.Models;
namespace Asemane.Web.Services;
public static class MediaRoles
{
    public static IEnumerable<ImageRole> ForKind(ContentKind kind) => kind switch
    {
        ContentKind.Project => new[] { ImageRole.General, ImageRole.HomeFirst, ImageRole.HomeSecond, ImageRole.ProjectCard, ImageRole.ProjectBanner, ImageRole.ProjectGallery },
        ContentKind.Team => new[] { ImageRole.General, ImageRole.TeamSquare, ImageRole.TeamLandscape },
        _ => new[] { ImageRole.General }
    };
    public static bool IsAllowed(ContentKind kind, ImageRole role) => ForKind(kind).Contains(role);
    public static bool IsSingle(ImageRole role) => role is >= ImageRole.HomeFirst and <= ImageRole.ProjectBanner or >= ImageRole.TeamSquare and <= ImageRole.TeamLandscape;
}
