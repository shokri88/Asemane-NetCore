using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
public class CategoriesController(AppDbContext db) : AdminController
{
    [HttpGet] public async Task<IActionResult> Index() => View(await db.Categories.AsNoTracking().Include(x => x.Translations).OrderBy(x => x.SortOrder).ToListAsync());
    [HttpGet] public async Task<IActionResult> Edit(int id = 0)
    {
        if (id == 0) return View(new CategoryForm { Kind = ContentKind.Project });
        var c = await db.Categories.AsNoTracking().Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == id);
        if (c is null) return NotFound(); var t = c.Translations.Single(x => x.Culture == "en");
        return View(new CategoryForm { Id = id, Kind = c.Kind, Name = t.Name, Slug = t.Slug, SortOrder = c.SortOrder });
    }
    [HttpPost] public async Task<IActionResult> Edit(CategoryForm model)
    {
        if (model.Kind is not (ContentKind.Project or ContentKind.Article)) return BadRequest();
        model.Slug = Slugs.Normalize(model.Slug);
        if (model.Slug.Length == 0) ModelState.AddModelError(nameof(model.Slug),"آدرس معتبر نیست.");
        if (await db.CategoryTranslations.AnyAsync(x => x.Culture == "en" && x.Category.Kind == model.Kind && x.Slug == model.Slug && x.CategoryId != model.Id)) ModelState.AddModelError(nameof(model.Slug),"آدرس تکراری است.");
        if (!ModelState.IsValid) return View(model);
        var c = model.Id == 0 ? new Category() : await db.Categories.Include(x => x.Translations).SingleOrDefaultAsync(x => x.Id == model.Id);
        if (c is null) return NotFound();
        if (model.Id != 0 && c.Kind != model.Kind && await db.Contents.AnyAsync(x => x.CategoryId == c.Id)) { ModelState.AddModelError("", "نوع دسته‌بندیِ استفاده‌شده قابل تغییر نیست."); return View(model); }
        c.Kind = model.Kind; c.SortOrder = model.SortOrder;
        var t = c.Translations.SingleOrDefault(x => x.Culture == "en");
        if (t is null) { t = new CategoryTranslation(); c.Translations.Add(t); }
        t.Kind = model.Kind; t.Name = model.Name.Trim(); t.Slug = model.Slug;
        if (model.Id == 0) db.Categories.Add(c);
        try { await db.SaveChangesAsync(); }
        catch (DbUpdateException) { ModelState.AddModelError("", "ذخیره انجام نشد؛ احتمالاً آدرس دسته تکراری است."); return View(model); }
        Success(); return RedirectToAction(nameof(Index));
    }
    [HttpPost] public async Task<IActionResult> Delete(int id)
    {
        if (await db.Contents.AnyAsync(x => x.CategoryId == id)) { TempData["Error"] = "این دسته‌بندی استفاده شده است؛ ابتدا دسته محتوای مرتبط را تغییر دهید."; return RedirectToAction(nameof(Index)); }
        var c = await db.Categories.FindAsync(id); if (c is null) return NotFound();
        db.Categories.Remove(c); await db.SaveChangesAsync(); Success(); return RedirectToAction(nameof(Index));
    }
}
