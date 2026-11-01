using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class ContactController(PublicContentService content) : Controller
{
    [HttpGet("/{culture:siteCulture}/contact")]
    public async Task<IActionResult> Index(string culture)
    {
        var model = await content.GetDetailAsync(culture,ContentKind.Page,"contact");
        if (model is null) return NotFound();
        ViewData["Culture"] = culture;
        ViewData["Seo"] = await content.GetDetailSeoAsync(model);
        return View(model);
    }
}
