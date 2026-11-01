using System.Xml.Linq;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Controllers;
public class SeoController(AppDbContext db, SeoService seo) : Controller
{
    [HttpGet("/robots.txt")]
    public IActionResult Robots() => Content(seo.IndexingEnabled ? $"User-agent: *\nDisallow: /admin\nSitemap: {seo.Absolute("/sitemap.xml")}\n" : "User-agent: *\nDisallow: /\n","text/plain");
    [HttpGet("/sitemap.xml")]
    public async Task<IActionResult> Sitemap()
    {
        XNamespace ns = "http://www.sitemaps.org/schemas/sitemap/0.9";
        var root = new XElement(ns+"urlset");
        if (seo.IndexingEnabled)
        {
            foreach (var culture in Languages.Enabled)
                foreach (var path in new[] { "/"+culture, "/"+culture+"/projects", "/"+culture+"/journal" }) root.Add(new XElement(ns+"url",new XElement(ns+"loc",seo.Absolute(path))));
            var now = DateTimeOffset.UtcNow;
            var entries = await db.ContentTranslations.AsNoTracking().Where(x => x.Published && !x.NoIndex && !x.ContentItem.IsDeleted && x.PublishedAt != null && x.PublishedAt <= now && Languages.Enabled.Contains(x.Culture)).Select(x => new { x.Kind, x.Culture, x.Slug, x.ContentItem.UpdatedAt }).ToListAsync();
            foreach (var t in entries) root.Add(new XElement(ns+"url",new XElement(ns+"loc",seo.Absolute(Slugs.Path(t.Kind,t.Culture,t.Slug))),new XElement(ns+"lastmod",t.UpdatedAt.ToString("O"))));
        }
        return Content(new XDocument(root).ToString(),"application/xml; charset=utf-8");
    }
}
