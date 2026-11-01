using Asemane.Web.Data;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Controllers;
public class MediaController(AppDbContext db, FileStorage storage) : Controller
{
    [HttpGet("/media/{id:int}")]
    public async Task<IActionResult> Get(int id)
    {
        var asset = await db.Media.AsNoTracking().Include(x => x.ContentItem).ThenInclude(x => x!.Translations).SingleOrDefaultAsync(x => x.Id == id);
        if (asset is null) return NotFound();
        var isPublic = await db.Settings.AnyAsync(x => x.LogoId == id) || (asset.ContentItem is { IsDeleted: false } && asset.ContentItem.Translations.Any(t => Languages.IsEnabled(t.Culture) && t.Published && t.PublishedAt <= DateTimeOffset.UtcNow));
        if (!isPublic && !(User.IsInRole("Admin") || User.IsInRole("Editor"))) return NotFound();
        var path = storage.GetPath(asset.StoredName); if (!System.IO.File.Exists(path)) return NotFound();
        // عدم کش عمومی: لغو انتشار باید دسترسی به تصویر پیش‌نویس را نیز قطع کند.
        Response.Headers.CacheControl = "no-store";
        return PhysicalFile(path,asset.ContentType,enableRangeProcessing: true);
    }
}
