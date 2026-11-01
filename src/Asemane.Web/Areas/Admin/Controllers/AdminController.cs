using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Areas.Admin.Controllers;
[Area("Admin"), Authorize(Roles = "Admin,Editor")]
public abstract class AdminController : Controller
{
    protected void Success(string text = "تغییرات ذخیره شد.") => TempData["Success"] = text;
}
