using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Controllers;
public class HomeController(SiteService site, SeoService seo) : Controller
{
    [HttpGet("/")] public IActionResult Root() => RedirectPermanent("/en");
    [HttpGet("/{culture:siteCulture}")]
    public async Task<IActionResult> Index(string culture)
    {
        if (!Languages.IsEnabled(culture)) return NotFound();
        var chrome = await site.GetAsync(culture);
        ViewData["Culture"] = culture;
        ViewData["Seo"] = seo.Page(chrome.Translation.HomeTitle,chrome.Translation.HomeDescription,"/"+culture,chrome);
        return View(await site.Published(culture,ContentKind.Project).Where(x => x.ContentItem.Featured).OrderBy(x => x.ContentItem.SortOrder).ThenBy(x => x.Id).Take(20).ToListAsync());
    }
}
