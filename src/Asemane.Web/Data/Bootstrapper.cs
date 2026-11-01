using Asemane.Web.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Data;
public static class Bootstrapper
{
    // فقط با فرمان صریح اجرا می‌شود؛ وب‌سایت هنگام راه‌اندازی دیتابیس را تغییر نمی‌دهد.
    public static async Task RunAsync(IServiceProvider services, IConfiguration config)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
        foreach (var role in new[] { "Admin", "Editor" })
            if (!await roles.RoleExistsAsync(role)) Check(await roles.CreateAsync(new IdentityRole(role)));
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var email = config["Bootstrap:Email"] ?? throw new InvalidOperationException("Set Bootstrap:Email with user-secrets/environment.");
        var user = await users.FindByEmailAsync(email);
        if (user is null)
        {
            var password = config["Bootstrap:Password"] ?? throw new InvalidOperationException("Set Bootstrap:Password with user-secrets/environment.");
            user = new ApplicationUser { UserName = email, Email = email, EmailConfirmed = true, DisplayName = "مدیر سایت" };
            Check(await users.CreateAsync(user, password));
        }
        if (!await users.IsInRoleAsync(user,"Admin")) Check(await users.AddToRoleAsync(user,"Admin"));
        if (!await db.Settings.AnyAsync()) db.Settings.Add(new SiteSettings { Translations = [new SiteTranslation { Culture = "en" }] });
        foreach (var key in new[] { "about", "contact" })
            if (!await db.Contents.AnyAsync(x => x.Kind == ContentKind.Page && x.Key == key))
                db.Contents.Add(new ContentItem { Kind = ContentKind.Page, Key = key, Translations = [new ContentTranslation { Culture = "en", Kind = ContentKind.Page, Title = key == "about" ? "About" : "Contact", Slug = key }] });
        await db.SaveChangesAsync();
    }
    private static void Check(IdentityResult result)
    {
        if (!result.Succeeded) throw new InvalidOperationException(string.Join("; ", result.Errors.Select(x => x.Description)));
    }
}
