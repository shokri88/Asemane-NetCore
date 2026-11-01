using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.ViewModels;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Services;

// فقط دریافت داده مشترک است؛ انتخاب صفحه و View در Controller مستقل هر بخش انجام می‌شود.
public class PublicContentService(AppDbContext db, SiteService site, SeoService seo)
{
    public async Task<PublicList?> GetListAsync(string culture, ContentKind kind, string? category, int page)
    {
        if (!Languages.IsEnabled(culture) || page < 1) return null;
        var query = site.Published(culture,kind);
        if (!string.IsNullOrEmpty(category))
        {
            if (!await db.CategoryTranslations.AnyAsync(x => x.Culture == culture && x.Slug == category && x.Category.Kind == kind)) return null;
            query = query.Where(x => x.ContentItem.Category != null && x.ContentItem.Category.Translations.Any(t => t.Culture == culture && t.Slug == category));
        }
        var total = await query.CountAsync();
        var pages = Math.Max(1,(int)Math.Ceiling(total / 12d));
        if (page > pages) return null;
        return new PublicList
        {
            Culture = culture, Kind = kind, Category = category, Page = page, Pages = pages,
            Items = await query.OrderBy(x => x.ContentItem.SortOrder).ThenByDescending(x => x.PublishedAt).ThenBy(x => x.Id).Skip((page-1)*12).Take(12).ToListAsync(),
            Categories = await db.CategoryTranslations.AsNoTracking().Where(x => x.Culture == culture && x.Category.Kind == kind).OrderBy(x => x.Category.SortOrder).ToListAsync()
        };
    }
    public async Task<PublicDetail?> GetDetailAsync(string culture, ContentKind kind, string slug)
    {
        if (!Languages.IsEnabled(culture)) return null;
        var translation = await site.Published(culture,kind).SingleOrDefaultAsync(x => x.Slug == slug);
        return translation is null ? null : new PublicDetail { Culture = culture, Translation = translation };
    }
    public async Task<string?> GetRedirectAsync(string culture, ContentKind kind, string slug)
    {
        if (!Languages.IsEnabled(culture)) return null;
        var redirect = await db.Redirects.AsNoTracking().SingleOrDefaultAsync(x => x.Kind == kind && x.Culture == culture && x.OldSlug == slug);
        if (redirect is null) return null;
        var target = await site.Published(culture,kind).SingleOrDefaultAsync(x => x.ContentItemId == redirect.ContentItemId);
        return target is null ? null : Slugs.Path(kind,culture,target.Slug);
    }
    public async Task<SeoModel> GetDetailSeoAsync(PublicDetail model)
    {
        var t = model.Translation;
        var meta = seo.Detail(t,await site.GetAsync(model.Culture));
        var now = DateTimeOffset.UtcNow;
        var alternatives = await db.ContentTranslations.AsNoTracking().Where(x => x.ContentItemId == t.ContentItemId && x.Published && !x.NoIndex && x.PublishedAt != null && x.PublishedAt <= now).ToListAsync();
        if (!meta.NoIndex)
            foreach (var alternate in alternatives.Where(x => Languages.IsEnabled(x.Culture))) meta.Alternates[alternate.Culture] = seo.Absolute(Slugs.Path(t.Kind,alternate.Culture,alternate.Slug));
        return meta;
    }
    public async Task<SeoModel> GetListSeoAsync(PublicList model, string title, string description)
    {
        var chrome = await site.GetAsync(model.Culture);
        var path = "/"+model.Culture+"/"+Slugs.Segment(model.Kind);
        if (model.Page > 1) path += "?page="+model.Page;
        var meta = seo.Page(title+" | "+chrome.Settings.Brand,description,path,chrome);
        meta.NoIndex |= !string.IsNullOrEmpty(model.Category) || model.Page > 1;
        return meta;
    }
}
