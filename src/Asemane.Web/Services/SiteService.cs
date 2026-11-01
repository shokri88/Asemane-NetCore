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
    public static string Alt(MediaAsset asset, string culture) => asset.Translations.FirstOrDefault(x => x.Culture == culture)?.Alt ?? "";
}
