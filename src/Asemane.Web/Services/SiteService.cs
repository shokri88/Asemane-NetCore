using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.ViewModels;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Services;
public class SiteService(AppDbContext db)
{
    private SiteSettings? settings;
    public async Task<SiteChrome> GetAsync(string culture)
    {
        settings ??= await db.Settings.AsNoTracking().Include(x => x.Translations).SingleOrDefaultAsync() ?? new SiteSettings();
        return new SiteChrome { Settings = settings, Culture = culture, Translation = settings.Translations.SingleOrDefault(x => x.Culture == culture) ?? new SiteTranslation { Culture = culture } };
    }
    public IQueryable<ContentTranslation> Published(string culture, ContentKind kind)
    {
        var now = DateTimeOffset.UtcNow;
        return db.ContentTranslations.AsNoTracking()
        .Where(x => x.Culture == culture && x.Kind == kind && x.Published && !x.ContentItem.IsDeleted && x.PublishedAt != null && x.PublishedAt <= now)
        .Include(x => x.ContentItem).ThenInclude(x => x.Category).ThenInclude(x => x!.Translations)
        .Include(x => x.ContentItem).ThenInclude(x => x.Images).ThenInclude(x => x.Translations);
    }
    public static MediaAsset? Cover(ContentItem item) => item.Images.OrderByDescending(x => x.IsCover).ThenBy(x => x.SortOrder).ThenBy(x => x.Id).FirstOrDefault();
    public static MediaAsset? TeamImage(ContentItem item, ImageRole role)
    {
        var selected = item.Images.FirstOrDefault(x => x.Role == role);
        if (selected is not null || role == ImageRole.TeamLandscapeSecond) return selected;
        return item.Images.Where(x => x.Role == ImageRole.General).OrderByDescending(x => x.IsCover).ThenBy(x => x.SortOrder).ThenBy(x => x.Id).FirstOrDefault();
    }
    public static MediaAsset? ProjectImage(ContentItem item, ImageRole role)
    {
        var selected = item.Images.FirstOrDefault(x => x.Role == role);
        if (selected is not null) return selected;
        // تا تعیین نقش تصاویر قدیمی، نمایش همان فایل‌های عمومی حفظ می‌شود.
        var legacy = item.Images.Where(x => x.Role == ImageRole.General).OrderByDescending(x => x.IsCover).ThenBy(x => x.SortOrder).ThenBy(x => x.Id);
        return role == ImageRole.HomeSecond ? legacy.FirstOrDefault(x => x.Id != ProjectImage(item,ImageRole.HomeFirst)?.Id) : legacy.FirstOrDefault();
    }
    public static List<MediaAsset> ProjectGallery(ContentItem item)
    {
        var selected = item.Images.Where(x => x.Role == ImageRole.ProjectGallery).ToList();
        return (selected.Count > 0 ? selected : item.Images.Where(x => x.Role == ImageRole.General)).OrderBy(x => x.SortOrder).ThenBy(x => x.Id).ToList();
    }
    public static string Alt(MediaAsset asset, string culture) => asset.Translations.FirstOrDefault(x => x.Culture == culture)?.Alt ?? "";
}
