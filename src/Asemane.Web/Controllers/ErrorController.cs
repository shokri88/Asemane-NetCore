using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Controllers;
public class ErrorController : Controller
{
    [Route("/status/{code:int}"), IgnoreAntiforgeryToken]
    public IActionResult Status(int code)
    {
        if (code is < 400 or > 599) return NotFound();
        Response.StatusCode = code; return View(code);
    }
    [HttpGet("/error")]
    public IActionResult Index() { Response.StatusCode = 500; return View(); }
}
