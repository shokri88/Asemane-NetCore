using System.Security.Claims;
using Asemane.Web.Models;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
[Authorize(Roles = "Admin")]
public class UsersController(UserManager<ApplicationUser> users) : AdminController
{
    [HttpGet] public async Task<IActionResult> Index() => View(await users.Users.OrderBy(x => x.Email).ToListAsync());
    [HttpGet] public IActionResult Create() => View(new UserForm());
    [HttpPost] public async Task<IActionResult> Create(UserForm model)
    {
        if (model.Role is not ("Admin" or "Editor")) return BadRequest();
        if (!ModelState.IsValid) return View(model);
        var user = new ApplicationUser { UserName = model.Email.Trim(), Email = model.Email.Trim(), EmailConfirmed = true, DisplayName = model.DisplayName };
        var result = await users.CreateAsync(user,model.Password);
        if (result.Succeeded)
        {
            var roleResult = await users.AddToRoleAsync(user,model.Role);
            if (roleResult.Succeeded) { Success("کاربر ساخته شد."); return RedirectToAction(nameof(Index)); }
            await users.DeleteAsync(user);
            result = roleResult;
        }
        foreach (var error in result.Errors) ModelState.AddModelError("",error.Description);
        return View(model);
    }
    [HttpGet] public async Task<IActionResult> ResetPassword(string id) => await users.FindByIdAsync(id) is null ? NotFound() : View(new ResetPasswordForm { Id = id });
    [HttpPost] public async Task<IActionResult> ResetPassword(ResetPasswordForm model)
    {
        if (!ModelState.IsValid) return View(model);
        var user = await users.FindByIdAsync(model.Id); if (user is null) return NotFound();
        var token = await users.GeneratePasswordResetTokenAsync(user);
        var result = await users.ResetPasswordAsync(user,token,model.Password);
        if (result.Succeeded) { Success("رمز تغییر کرد؛ نشست‌های قبلی باطل می‌شوند."); return RedirectToAction(nameof(Index)); }
        foreach (var error in result.Errors) ModelState.AddModelError("",error.Description);
        return View(model);
    }
    [HttpPost] public async Task<IActionResult> ToggleLock(string id)
    {
        if (id == User.FindFirstValue(ClaimTypes.NameIdentifier)) { TempData["Error"] = "امکان غیرفعال‌کردن حساب خودتان وجود ندارد."; return RedirectToAction(nameof(Index)); }
        var user = await users.FindByIdAsync(id); if (user is null) return NotFound();
        // حساب دیگر مدیر نیز قفل نمی‌شود؛ جلوگیری از حذف دسترسی آخرین مدیر.
        if (await users.IsInRoleAsync(user,"Admin")) { TempData["Error"] = "غیرفعال‌کردن مدیر از این بخش مجاز نیست."; return RedirectToAction(nameof(Index)); }
        await users.SetLockoutEnabledAsync(user,true);
        await users.SetLockoutEndDateAsync(user,user.LockoutEnd > DateTimeOffset.UtcNow ? null : DateTimeOffset.MaxValue);
        await users.UpdateSecurityStampAsync(user);
        Success(); return RedirectToAction(nameof(Index));
    }
}
