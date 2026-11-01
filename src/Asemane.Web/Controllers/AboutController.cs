using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Controllers;
public class AboutController(PublicContentService content, SiteService site) : Controller
{
    [HttpGet("/{culture:siteCulture}/about")]
    public async Task<IActionResult> Index(string culture)
    {
        var model = await content.GetDetailAsync(culture,ContentKind.Page,"about");
        if (model is null) return NotFound();
        model.Team = await site.Published(culture,ContentKind.Team).OrderBy(x => x.ContentItem.SortOrder).ThenBy(x => x.Id).ToListAsync();
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
