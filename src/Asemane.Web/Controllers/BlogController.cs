using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class BlogController(PublicContentService content) : Controller
{
    [HttpGet("/{culture:siteCulture}/journal")]
    public async Task<IActionResult> Index(string culture, string? category, int page = 1)
    {
        var model = await content.GetListAsync(culture,ContentKind.Article,category,page);
        if (model is null) return NotFound();
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetListSeoAsync(model,"Journal","News and insights from our architectural studio.");
        return View(model);
    }
    [HttpGet("/{culture:siteCulture}/journal/{slug}")]
    public async Task<IActionResult> Details(string culture, string slug)
    {
        var model = await content.GetDetailAsync(culture,ContentKind.Article,slug);
        if (model is null)
        {
            var redirect = await content.GetRedirectAsync(culture,ContentKind.Article,slug);
            return redirect is null ? NotFound() : RedirectPermanent(redirect);
        }
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
