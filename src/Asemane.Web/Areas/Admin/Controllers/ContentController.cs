using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
public class ContentController(AppDbContext db) : AdminController
{
    [HttpGet]
    public async Task<IActionResult> Index(ContentKind kind = ContentKind.Project, string q = "", string status = "", string sort = "updated", int page = 1)
    {
        if (!Enum.IsDefined(kind)) return NotFound();
        var query = db.Contents.AsNoTracking().Include(x => x.Translations).Where(x => x.Kind == kind && !x.IsDeleted);
        if (!string.IsNullOrWhiteSpace(q)) query = query.Where(x => x.Translations.Any(t => t.Culture == "en" && t.Title.Contains(q)));
        if (status == "published") query = query.Where(x => x.Translations.Any(t => t.Culture == "en" && t.Published));
        if (status == "draft") query = query.Where(x => !x.Translations.Any(t => t.Culture == "en" && t.Published));
        query = sort switch { "title" => query.OrderBy(x => x.Translations.Where(t => t.Culture == "en").Select(t => t.Title).FirstOrDefault()).ThenBy(x => x.Id), "order" => query.OrderBy(x => x.SortOrder).ThenBy(x => x.Id), _ => query.OrderByDescending(x => x.UpdatedAt).ThenByDescending(x => x.Id) };
        var total = await query.CountAsync();
        var pages = Math.Max(1,(int)Math.Ceiling(total / 20d)); page = Math.Clamp(page,1,pages);
        return View(new ContentList { Kind = kind, Query = q, Status = status, Sort = sort, Page = page, Pages = pages, Total = total, Items = await query.Skip((page - 1)*20).Take(20).ToListAsync() });
    }
    [HttpGet]
    public async Task<IActionResult> Edit(int id = 0, ContentKind kind = ContentKind.Project)
    {
        if (!Enum.IsDefined(kind)) return NotFound();
        var model = new ContentForm { Kind = kind };
        if (id != 0)
        {
            var item = await db.Contents.AsNoTracking().Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
            if (item is null) return NotFound();
            var t = item.Translations.Single(x => x.Culture == "en");
            model = new ContentForm { Id = id, Kind = item.Kind, Version = item.Version, Title = t.Title, Slug = t.Slug, Summary = t.Summary, Body = t.Body, Subtitle = t.Subtitle, Location = t.Location, ProjectStatus = t.ProjectStatus, AuthorName = t.AuthorName, SeoTitle = t.SeoTitle, MetaDescription = t.MetaDescription, NoIndex = t.NoIndex, Published = t.Published, Featured = item.Featured, SortOrder = item.SortOrder, CategoryId = item.CategoryId, Area = item.Area, Year = item.Year };
        }
        await Categories(model); return View(model);
    }
    [HttpPost]
    public async Task<IActionResult> Edit([FromForm] ContentForm model)
    {
        if (!Enum.IsDefined(model.Kind) || model.Culture != "en") return BadRequest();
        model.Slug = Slugs.Normalize(model.Slug);
        if (model.Slug.Length == 0) ModelState.AddModelError(nameof(model.Slug),"آدرس معتبر وارد کنید.");
        if (model.Published && (string.IsNullOrWhiteSpace(model.MetaDescription) || string.IsNullOrWhiteSpace(model.Body))) ModelState.AddModelError("", "برای انتشار، متن محتوا و توضیحات متا را تکمیل کنید.");
        if (model.CategoryId.HasValue && !await db.Categories.AnyAsync(x => x.Id == model.CategoryId && x.Kind == model.Kind)) ModelState.AddModelError(nameof(model.CategoryId),"دسته‌بندی معتبر نیست.");
        if (await db.ContentTranslations.AnyAsync(x => x.Kind == model.Kind && x.Culture == "en" && x.Slug == model.Slug && x.ContentItemId != model.Id) || await db.Redirects.AnyAsync(x => x.Kind == model.Kind && x.Culture == "en" && x.OldSlug == model.Slug && x.ContentItemId != model.Id)) ModelState.AddModelError(nameof(model.Slug),"این آدرس قبلاً استفاده شده است.");
        ContentItem? item = model.Id == 0 ? new ContentItem { Kind = model.Kind } : await db.Contents.Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == model.Id && !x.IsDeleted);
        if (item is null || item.Kind != model.Kind) return NotFound();
        if (model.Id != 0 && item.Version != model.Version) ModelState.AddModelError("", "این محتوا توسط شخص دیگری تغییر کرده است. صفحه را دوباره باز کنید.");
        if (item.Kind == ContentKind.Page && item.Key is "about" or "contact" && model.Slug != item.Key) ModelState.AddModelError(nameof(model.Slug),"آدرس صفحه سیستمی قابل تغییر نیست.");
        if (!ModelState.IsValid) { await Categories(model); return View(model); }
        var t = item.Translations.SingleOrDefault(x => x.Culture == "en");
        if (t is null) { t = new ContentTranslation { Culture = "en", Kind = item.Kind }; item.Translations.Add(t); }
        if (t.Slug != "" && t.Slug != model.Slug)
        {
            var reverting = await db.Redirects.SingleOrDefaultAsync(x => x.Kind == item.Kind && x.Culture == "en" && x.OldSlug == model.Slug);
            if (reverting is not null) db.Redirects.Remove(reverting);
            if (!await db.Redirects.AnyAsync(x => x.Kind == item.Kind && x.Culture == "en" && x.OldSlug == t.Slug)) db.Redirects.Add(new SlugRedirect { Kind = item.Kind, OldSlug = t.Slug, ContentItemId = item.Id });
        }
        t.Title = model.Title.Trim(); t.Slug = model.Slug; t.Summary = model.Summary; t.Body = model.Body;
        t.Subtitle = model.Subtitle; t.Location = model.Location; t.ProjectStatus = model.ProjectStatus; t.AuthorName = model.AuthorName;
        t.SeoTitle = model.SeoTitle; t.MetaDescription = model.MetaDescription; t.NoIndex = model.NoIndex;
        if (model.Published && t.PublishedAt is null) t.PublishedAt = DateTimeOffset.UtcNow;
        t.Published = model.Published;
        item.Featured = model.Featured; item.SortOrder = model.SortOrder; item.CategoryId = model.CategoryId;
        item.Area = model.Area; item.Year = model.Year; item.UpdatedAt = DateTimeOffset.UtcNow; item.Version = Guid.NewGuid();
        if (model.Id == 0) db.Contents.Add(item);
        try { await db.SaveChangesAsync(); }
        catch (DbUpdateConcurrencyException) { ModelState.AddModelError("", "محتوا هم‌زمان تغییر کرده است. صفحه را دوباره باز کنید."); await Categories(model); return View(model); }
        catch (DbUpdateException) { ModelState.AddModelError("", "ذخیره انجام نشد؛ احتمالاً آدرس هم‌زمان ثبت شده است. دوباره بررسی کنید."); await Categories(model); return View(model); }
        Success(); return RedirectToAction(nameof(Edit),new { id = item.Id });
    }
    [HttpPost]
    public async Task<IActionResult> Delete(int id, Guid version)
    {
        var item = await db.Contents.SingleOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
        if (item is null) return NotFound();
        if (item.Version != version) { TempData["Error"] = "محتوا تغییر کرده؛ صفحه را تازه کنید."; return RedirectToAction(nameof(Index),new { kind = item.Kind }); }
        if (item.Kind == ContentKind.Page && item.Key is "about" or "contact") { TempData["Error"] = "صفحات سیستمی حذف نمی‌شوند؛ برای پنهان‌کردن، انتشار را غیرفعال کنید."; return RedirectToAction(nameof(Index),new { kind = item.Kind }); }
        item.IsDeleted = true; item.Version = Guid.NewGuid(); item.UpdatedAt = DateTimeOffset.UtcNow;
        try { await db.SaveChangesAsync(); Success("محتوا حذف شد؛ تصاویر برای بازیابی نگهداری شدند."); }
        catch (DbUpdateConcurrencyException) { TempData["Error"] = "محتوا هم‌زمان تغییر کرده؛ دوباره تلاش کنید."; }
        return RedirectToAction(nameof(Index),new { kind = item.Kind });
    }
    private async Task Categories(ContentForm model) => model.Categories = await db.CategoryTranslations.Where(x => x.Culture == "en" && x.Category.Kind == model.Kind).OrderBy(x => x.Category.SortOrder).Select(x => new SelectListItem(x.Name,x.CategoryId.ToString())).ToListAsync();
}
