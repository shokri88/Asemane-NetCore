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
    [HttpPost] public async Task<IActionResult> Upload(int contentId, IFormFile? file, string alt, CancellationToken ct)
    {
        var item = await db.Contents.Include(x => x.Images).SingleOrDefaultAsync(x => x.Id == contentId && !x.IsDeleted,ct);
        if (item is null) return NotFound();
        if (file is null || string.IsNullOrWhiteSpace(alt) || alt.Length > 250) { TempData["Error"] = "تصویر و متن جایگزین معتبر الزامی است."; return RedirectToAction(nameof(Index),new { contentId }); }
        try
        {
            var saved = await storage.SaveAsync(file,ct);
            var asset = new MediaAsset { ContentItemId = contentId, StoredName = saved.Name, ContentType = saved.Mime, Bytes = saved.Bytes, OriginalName = Path.GetFileName(file.FileName)[..Math.Min(Path.GetFileName(file.FileName).Length,250)], IsCover = !item.Images.Any(x => x.IsCover), SortOrder = item.Images.Count, Translations = [new MediaTranslation { Alt = alt.Trim() }] };
            db.Media.Add(asset);
            try { await db.SaveChangesAsync(ct); } catch { storage.Delete(saved.Name); throw; }
            Success("تصویر بارگذاری شد.");
        }
        catch (InvalidDataException ex) { TempData["Error"] = ex.Message; }
        return RedirectToAction(nameof(Index),new { contentId });
    }
    [HttpPost] public async Task<IActionResult> Update(MediaForm model)
    {
        var image = await db.Media.Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == model.Id && x.ContentItemId == model.ContentId);
        if (image is null) return NotFound();
        if (!ModelState.IsValid) { TempData["Error"] = "متن جایگزین و ترتیب تصویر را بررسی کنید."; return RedirectToAction(nameof(Index),new { contentId = model.ContentId }); }
        if (model.IsCover)
            foreach (var other in await db.Media.Where(x => x.ContentItemId == model.ContentId && x.IsCover).ToListAsync()) other.IsCover = false;
        image.IsCover = model.IsCover; image.SortOrder = model.SortOrder;
        var t = image.Translations.SingleOrDefault(x => x.Culture == "en");
        if (t is null) { t = new MediaTranslation(); image.Translations.Add(t); }
        t.Alt = model.Alt.Trim(); t.Caption = model.Caption;
        await db.SaveChangesAsync(); Success(); return RedirectToAction(nameof(Index),new { contentId = model.ContentId });
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
