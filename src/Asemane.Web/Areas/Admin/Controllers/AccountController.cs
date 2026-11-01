using Asemane.Web.Models;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
namespace Asemane.Web.Areas.Admin.Controllers;
[Area("Admin")]
public class AccountController(SignInManager<ApplicationUser> signIn, UserManager<ApplicationUser> users) : Controller
{
    [HttpGet, AllowAnonymous] public IActionResult Login(string? returnUrl) => View(new LoginForm { ReturnUrl = returnUrl });
    [HttpPost, AllowAnonymous]
    public async Task<IActionResult> Login(LoginForm model)
    {
        if (!ModelState.IsValid) return View(model);
        var user = await users.FindByEmailAsync(model.Email);
        var result = user is null ? Microsoft.AspNetCore.Identity.SignInResult.Failed : await signIn.PasswordSignInAsync(user,model.Password,model.RememberMe,true);
        if (!result.Succeeded) { ModelState.AddModelError("", "ورود ناموفق بود. اطلاعات را بررسی کنید؛ پس از تلاش‌های مکرر، ورود موقتاً قفل می‌شود."); return View(model); }
        if (!(await users.IsInRoleAsync(user!,"Admin") || await users.IsInRoleAsync(user!,"Editor")))
        { await signIn.SignOutAsync(); return Forbid(); }
        return LocalRedirect(Url.IsLocalUrl(model.ReturnUrl) ? model.ReturnUrl! : "/admin");
    }
    [HttpPost, Authorize] public async Task<IActionResult> Logout() { await signIn.SignOutAsync(); return RedirectToAction(nameof(Login)); }
    [HttpGet] public IActionResult Denied() { Response.StatusCode = 403; return View(); }
}
