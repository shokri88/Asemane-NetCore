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
        // آمار همان جایگاه‌های قالب اصلی را با پروژه‌های منتشرشده پر می‌کند.
        var statuses = await site.Published(culture,ContentKind.Project).Select(x => x.ProjectStatus).ToListAsync();
        model.TotalProjects = statuses.Count;
        model.DesignProjects = statuses.Count(x => x.Equals("Design Development",StringComparison.OrdinalIgnoreCase));
        model.ConstructionProjects = statuses.Count(x => x.Equals("Under Construction",StringComparison.OrdinalIgnoreCase));
        model.CompletedProjects = statuses.Count(x => x.Equals("Completed",StringComparison.OrdinalIgnoreCase));
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
