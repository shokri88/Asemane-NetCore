using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
[Authorize(Roles = "Admin")]
public class SettingsController(AppDbContext db, FileStorage storage) : AdminController
{
    [HttpGet] public async Task<IActionResult> Index()
    {
        var s = await db.Settings.AsNoTracking().Include(x => x.Translations).SingleAsync(); var t = s.Translations.Single(x => x.Culture == "en");
        return View(new SettingsForm { AboutTotalTitle = t.AboutTotalTitle, AboutTotalValue = s.AboutTotalValue, AboutDesignTitle = t.AboutDesignTitle, AboutDesignValue = s.AboutDesignValue, AboutConstructionTitle = t.AboutConstructionTitle, AboutConstructionValue = s.AboutConstructionValue, AboutCompletedTitle = t.AboutCompletedTitle, AboutCompletedValue = s.AboutCompletedValue, Brand = s.Brand, Phone = s.Phone, PostalCode = s.PostalCode, MapEmbedUrl = s.MapEmbedUrl, Email = s.Email, InstagramUrl = s.InstagramUrl, Latitude = s.Latitude, Longitude = s.Longitude, HomeTitle = t.HomeTitle, HomeDescription = t.HomeDescription, Address = t.Address, LogoId = s.LogoId, CompletedProjects = s.CompletedProjects, YearsExperience = s.YearsExperience, TeamCount = s.TeamCount });
    }
    [HttpPost] public async Task<IActionResult> Index(SettingsForm model, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(model.InstagramUrl) && (!Uri.TryCreate(model.InstagramUrl,UriKind.Absolute,out var url) || url.Scheme != "https")) ModelState.AddModelError(nameof(model.InstagramUrl),"آدرس باید با https شروع شود.");
        if (!string.IsNullOrWhiteSpace(model.MapEmbedUrl) && !ContactMap.IsAllowed(model.MapEmbedUrl)) ModelState.AddModelError(nameof(model.MapEmbedUrl),"فقط لینک HTTPS نقشه Google Maps مجاز است؛ کد iframe را وارد نکنید.");
        if (model.Latitude.HasValue != model.Longitude.HasValue) ModelState.AddModelError("", "هر دو مختصات را تکمیل کنید.");
        if (!ModelState.IsValid) return View(model);
        var s = await db.Settings.Include(x => x.Translations).SingleAsync(ct); var t = s.Translations.Single(x => x.Culture == "en");
        model.LogoId = s.LogoId;
        string? newName = null; MediaAsset? previous = null;
        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        try
        {
            if (model.Logo is not null)
            {
                var file = await storage.SaveAsync(model.Logo,ct); newName = file.Name;
                if (s.LogoId.HasValue) previous = await db.Media.FindAsync([s.LogoId.Value],ct);
                var asset = new MediaAsset { StoredName = file.Name, OriginalName = "logo", ContentType = file.Mime, Bytes = file.Bytes, Translations = [new MediaTranslation { Alt = model.Brand }] };
                db.Media.Add(asset); await db.SaveChangesAsync(ct); s.LogoId = asset.Id;
            }
            s.AboutTotalValue = model.AboutTotalValue; t.AboutTotalTitle = model.AboutTotalTitle.Trim();
            s.AboutDesignValue = model.AboutDesignValue; t.AboutDesignTitle = model.AboutDesignTitle.Trim();
            s.AboutConstructionValue = model.AboutConstructionValue; t.AboutConstructionTitle = model.AboutConstructionTitle.Trim();
            s.AboutCompletedValue = model.AboutCompletedValue; t.AboutCompletedTitle = model.AboutCompletedTitle.Trim();
            s.PostalCode = model.PostalCode.Trim(); s.MapEmbedUrl = model.MapEmbedUrl.Trim();
            s.Brand = model.Brand; s.Phone = model.Phone ?? ""; s.Email = model.Email ?? ""; s.InstagramUrl = model.InstagramUrl ?? "";
            s.Latitude = model.Latitude; s.Longitude = model.Longitude; s.CompletedProjects = model.CompletedProjects; s.YearsExperience = model.YearsExperience; s.TeamCount = model.TeamCount;
            t.HomeTitle = model.HomeTitle; t.HomeDescription = model.HomeDescription; t.Address = model.Address;
            if (previous is not null && previous.ContentItemId is null) db.Media.Remove(previous);
            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
        }
        catch (InvalidDataException ex)
        {
            if (newName is not null) storage.Delete(newName);
            ModelState.AddModelError(nameof(model.Logo),ex.Message); return View(model);
        }
        catch { if (newName is not null) storage.Delete(newName); throw; }
        if (previous is not null && previous.ContentItemId is null) storage.Delete(previous.StoredName);
        Success(); return RedirectToAction(nameof(Index));
    }
}
