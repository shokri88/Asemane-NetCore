using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Controllers;
public class SiteController(AppDbContext db, SiteService site, SeoService seo) : Controller
{
    [HttpGet("/")] public IActionResult Root() => RedirectPermanent("/en");
    [HttpGet("/{culture:siteCulture}")]
    public async Task<IActionResult> Home(string culture)
    {
        if (!Languages.IsEnabled(culture)) return NotFound();
        var chrome = await site.GetAsync(culture);
        ViewData["Culture"] = culture;
        ViewData["Seo"] = seo.Page(chrome.Translation.HomeTitle,chrome.Translation.HomeDescription,"/"+culture,chrome);
        return View(await site.Published(culture,ContentKind.Project).Where(x => x.ContentItem.Featured).OrderBy(x => x.ContentItem.SortOrder).ThenBy(x => x.Id).Take(20).ToListAsync());
    }
    [HttpGet("/{culture:siteCulture}/projects")]
    public Task<IActionResult> Projects(string culture, string? category, int page = 1) => Listing(culture,ContentKind.Project,category,page);
    [HttpGet("/{culture:siteCulture}/journal")]
    public Task<IActionResult> Journal(string culture, string? category, int page = 1) => Listing(culture,ContentKind.Article,category,page);
    private async Task<IActionResult> Listing(string culture, ContentKind kind, string? category, int page)
    {
        if (!Languages.IsEnabled(culture) || page < 1) return NotFound();
        var query = site.Published(culture,kind);
        if (!string.IsNullOrEmpty(category))
        {
            if (!await db.CategoryTranslations.AnyAsync(x => x.Culture == culture && x.Slug == category && x.Category.Kind == kind)) return NotFound();
            query = query.Where(x => x.ContentItem.Category != null && x.ContentItem.Category.Translations.Any(t => t.Culture == culture && t.Slug == category));
        }
        var total = await query.CountAsync(); var pages = Math.Max(1,(int)Math.Ceiling(total / 12d));
        if (page > pages) return NotFound();
        var chrome = await site.GetAsync(culture); var title = kind == ContentKind.Project ? "Projects" : "Journal";
        var path = "/"+culture+"/"+Slugs.Segment(kind); if (page > 1) path += "?page="+page;
        var meta = seo.Page(title+" | "+chrome.Settings.Brand,kind == ContentKind.Project ? "Explore our architectural and interior design projects." : "News and insights from our architectural studio.",path,chrome);
        meta.NoIndex |= !string.IsNullOrEmpty(category) || page > 1;
        ViewData["Seo"] = meta; ViewData["Culture"] = culture;
        return View("Listing",new PublicList { Culture = culture, Kind = kind, Category = category, Page = page, Pages = pages, Items = await query.OrderBy(x => x.ContentItem.SortOrder).ThenByDescending(x => x.PublishedAt).ThenBy(x => x.Id).Skip((page-1)*12).Take(12).ToListAsync(), Categories = await db.CategoryTranslations.AsNoTracking().Where(x => x.Culture == culture && x.Category.Kind == kind).OrderBy(x => x.Category.SortOrder).ToListAsync() });
    }
    [HttpGet("/{culture:siteCulture}/projects/{slug}")] public Task<IActionResult> Project(string culture,string slug) => Detail(culture,ContentKind.Project,slug);
    [HttpGet("/{culture:siteCulture}/journal/{slug}")] public Task<IActionResult> Article(string culture,string slug) => Detail(culture,ContentKind.Article,slug);
    [HttpGet("/{culture:siteCulture}/team/{slug}")] public Task<IActionResult> Team(string culture,string slug) => Detail(culture,ContentKind.Team,slug);
    [HttpGet("/{culture:siteCulture}/pages/{slug}")] public Task<IActionResult> Page(string culture,string slug) => slug is "about" or "contact" ? Task.FromResult<IActionResult>(RedirectPermanent("/"+culture+"/"+slug)) : Detail(culture,ContentKind.Page,slug);
    [HttpGet("/{culture:siteCulture}/about")] public Task<IActionResult> About(string culture) => Detail(culture,ContentKind.Page,"about");
    [HttpGet("/{culture:siteCulture}/contact")] public Task<IActionResult> Contact(string culture) => Detail(culture,ContentKind.Page,"contact");
    private async Task<IActionResult> Detail(string culture,ContentKind kind,string slug)
    {
        if (!Languages.IsEnabled(culture)) return NotFound();
        var translation = await site.Published(culture,kind).SingleOrDefaultAsync(x => x.Slug == slug);
        if (translation is null)
        {
            var redirect = await db.Redirects.AsNoTracking().SingleOrDefaultAsync(x => x.Kind == kind && x.Culture == culture && x.OldSlug == slug);
            if (redirect is null) return NotFound();
            var target = await site.Published(culture,kind).SingleOrDefaultAsync(x => x.ContentItemId == redirect.ContentItemId);
            return target is null ? NotFound() : RedirectPermanent(Slugs.Path(kind,culture,target.Slug));
        }
        var meta = seo.Detail(translation,await site.GetAsync(culture));
        var now = DateTimeOffset.UtcNow;
        var alternatives = await db.ContentTranslations.AsNoTracking().Where(x => x.ContentItemId == translation.ContentItemId && x.Published && !x.NoIndex && x.PublishedAt != null && x.PublishedAt <= now).ToListAsync();
        if (!meta.NoIndex)
            foreach (var t in alternatives.Where(x => Languages.IsEnabled(x.Culture))) meta.Alternates[t.Culture] = seo.Absolute(Slugs.Path(kind,t.Culture,t.Slug));
        ViewData["Seo"] = meta; ViewData["Culture"] = culture;
        var model = new PublicDetail { Culture = culture, Translation = translation };
        if (kind == ContentKind.Page && translation.Slug == "about") model.Team = await site.Published(culture,ContentKind.Team).OrderBy(x => x.ContentItem.SortOrder).ThenBy(x => x.Id).ToListAsync();
        return View("Detail",model);
    }
    [Route("/status/{code:int}"), IgnoreAntiforgeryToken]
    public IActionResult Status(int code)
    {
        if (code is < 400 or > 599) return NotFound();
        Response.StatusCode = code; return View("Status",code);
    }
    [HttpGet("/error")]
    public IActionResult Error() { Response.StatusCode = 500; return View(); }
}
