using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class TeamController(PublicContentService content) : Controller
{
    [HttpGet("/{culture:siteCulture}/team/{slug}")]
    public async Task<IActionResult> Details(string culture, string slug)
    {
        var model = await content.GetDetailAsync(culture,ContentKind.Team,slug);
        if (model is null)
        {
            var redirect = await content.GetRedirectAsync(culture,ContentKind.Team,slug);
            return redirect is null ? NotFound() : RedirectPermanent(redirect);
        }
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
