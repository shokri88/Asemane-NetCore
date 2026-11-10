using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
public class MediaController(AppDbContext db, FileStorage storage) : AdminController
{
    [HttpGet] public async Task<IActionResult> Index(int contentId)
    {
        var item = await db.Contents.AsNoTracking().Include(x => x.Translations).Include(x => x.Images).ThenInclude(x => x.Translations).SingleOrDefaultAsync(x => x.Id == contentId && !x.IsDeleted);
        return item is null ? NotFound() : View(item);
    }
    [HttpPost] public async Task<IActionResult> Upload(int contentId, IFormFile? file, string alt, CancellationToken ct, ImageRole role)
    {
        var item = await db.Contents.Include(x => x.Images).SingleOrDefaultAsync(x => x.Id == contentId && !x.IsDeleted,ct);
        if (item is null) return NotFound();
        if (!ModelState.IsValid || !MediaRoles.IsAllowed(item.Kind,role)) return BadRequest();
        if (MediaRoles.IsSingle(role) && item.Images.Any(x => x.Role == role))
        { TempData["Error"] = "این جایگاه قبلاً تصویر دارد؛ ابتدا نقش تصویر قبلی را تغییر دهید یا آن را حذف کنید."; return RedirectToAction(nameof(Index),new { contentId }); }
        if (file is null || string.IsNullOrWhiteSpace(alt) || alt.Length > 250) { TempData["Error"] = "تصویر و متن جایگزین معتبر الزامی است."; return RedirectToAction(nameof(Index),new { contentId }); }
        try
        {
            var saved = await storage.SaveAsync(file,ct);
            var asset = new MediaAsset { ContentItemId = contentId, StoredName = saved.Name, ContentType = saved.Mime, Bytes = saved.Bytes, OriginalName = Path.GetFileName(file.FileName)[..Math.Min(Path.GetFileName(file.FileName).Length,250)], SortOrder = item.Images.Count, Translations = [new MediaTranslation { Alt = alt.Trim() }] };
            asset.Role = role;
            db.Media.Add(asset);
            try { await db.SaveChangesAsync(ct); } catch { storage.Delete(saved.Name); throw; }
            Success("تصویر بارگذاری شد.");
        }
        catch (InvalidDataException ex) { TempData["Error"] = ex.Message; }
        catch (DbUpdateException) { TempData["Error"] = "ثبت تصویر انجام نشد؛ ممکن است این جایگاه هم‌زمان پر شده باشد. صفحه را تازه کنید."; }
        return RedirectToAction(nameof(Index),new { contentId });
    }
    [HttpPost] public async Task<IActionResult> Update(MediaForm model)
    {
        var image = await db.Media.Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == model.Id && x.ContentItemId == model.ContentId);
        if (image is null) return NotFound();
        var item = await db.Contents.SingleOrDefaultAsync(x => x.Id == model.ContentId && !x.IsDeleted);
        if (item is null) return NotFound();
        if (!MediaRoles.IsAllowed(item.Kind,model.Role)) ModelState.AddModelError(nameof(model.Role),"این نقش برای نوع محتوا مجاز نیست.");
        if (MediaRoles.IsSingle(model.Role) && await db.Media.AnyAsync(x => x.ContentItemId == model.ContentId && x.Role == model.Role && x.Id != image.Id)) ModelState.AddModelError(nameof(model.Role),"این جایگاه قبلاً تصویر دارد.");
        if (!ModelState.IsValid) { TempData["Error"] = "نوع تصویر، جایگاه تکراری، متن جایگزین و ترتیب تصویر را بررسی کنید."; return RedirectToAction(nameof(Index),new { contentId = model.ContentId }); }
        image.SortOrder = model.SortOrder; image.Role = model.Role;
        var t = image.Translations.SingleOrDefault(x => x.Culture == "en");
        if (t is null) { t = new MediaTranslation(); image.Translations.Add(t); }
        t.Alt = model.Alt.Trim(); t.Caption = model.Caption;
        try { await db.SaveChangesAsync(); Success(); }
        catch (DbUpdateException) { TempData["Error"] = "ثبت مشخصات انجام نشد؛ ممکن است جایگاه تصویر هم‌زمان تغییر کرده باشد."; }
        return RedirectToAction(nameof(Index),new { contentId = model.ContentId });
    }
    [HttpPost] public async Task<IActionResult> Delete(int id, int contentId)
    {
        var asset = await db.Media.SingleOrDefaultAsync(x => x.Id == id && x.ContentItemId == contentId);
        if (asset is null) return NotFound();
        if (await db.Settings.AnyAsync(x => x.LogoId == id)) { TempData["Error"] = "تصویر به‌عنوان لوگو استفاده شده است."; return RedirectToAction(nameof(Index),new { contentId }); }
        db.Media.Remove(asset); await db.SaveChangesAsync(); storage.Delete(asset.StoredName);
        Success("تصویر حذف شد."); return RedirectToAction(nameof(Index),new { contentId });
    }
}
