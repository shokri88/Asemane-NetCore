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
    public static MediaAsset? ArticleImage(ContentItem item, ImageRole role) => item.Images.FirstOrDefault(x => x.Role == role);
    public static MediaAsset? TeamImage(ContentItem item, ImageRole role) => item.Images.FirstOrDefault(x => x.Role == role);
    public static MediaAsset? ProjectImage(ContentItem item, ImageRole role) => item.Images.FirstOrDefault(x => x.Role == role);
    public static MediaAsset? PageImage(ContentItem item) => item.Images.FirstOrDefault(x => x.Role == ImageRole.PageBanner);
    public static List<MediaAsset> ProjectGallery(ContentItem item) => item.Images.Where(x => x.Role == ImageRole.ProjectGallery).OrderBy(x => x.SortOrder).ThenBy(x => x.Id).ToList();
    public static string Alt(MediaAsset asset, string culture) => asset.Translations.FirstOrDefault(x => x.Culture == culture)?.Alt ?? "";
}
