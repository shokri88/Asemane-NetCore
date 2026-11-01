using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class ProjectController(PublicContentService content) : Controller
{
    [HttpGet("/{culture:siteCulture}/projects")]
    public async Task<IActionResult> Index(string culture, string? category, int page = 1)
    {
        var model = await content.GetListAsync(culture,ContentKind.Project,category,page);
        if (model is null) return NotFound();
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetListSeoAsync(model,"Projects","Explore our architectural and interior design projects.");
        return View(model);
    }
    [HttpGet("/{culture:siteCulture}/projects/{slug}")]
    public async Task<IActionResult> Details(string culture, string slug)
    {
        var model = await content.GetDetailAsync(culture,ContentKind.Project,slug);
        if (model is null)
        {
            var redirect = await content.GetRedirectAsync(culture,ContentKind.Project,slug);
            return redirect is null ? NotFound() : RedirectPermanent(redirect);
        }
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
