using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class PageController(PublicContentService content) : Controller
{
    [HttpGet("/{culture:siteCulture}/pages/{slug}")]
    public async Task<IActionResult> Details(string culture, string slug)
    {
        if (slug is "about" or "contact") return RedirectPermanent("/"+culture+"/"+slug);
        var model = await content.GetDetailAsync(culture,ContentKind.Page,slug);
        if (model is null)
        {
            var redirect = await content.GetRedirectAsync(culture,ContentKind.Page,slug);
            return redirect is null ? NotFound() : RedirectPermanent(redirect);
        }
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
