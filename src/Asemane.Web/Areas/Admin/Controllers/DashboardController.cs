using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Areas.Admin.Controllers;
public class DashboardController(AppDbContext db) : AdminController
{
    public async Task<IActionResult> Index() => View(new DashboardModel
    {
        Projects = await db.Contents.CountAsync(x => !x.IsDeleted && x.Kind == ContentKind.Project),
        Articles = await db.Contents.CountAsync(x => !x.IsDeleted && x.Kind == ContentKind.Article),
        Drafts = await db.Contents.CountAsync(x => !x.IsDeleted && !x.Translations.Any(t => t.Published)),
        Images = await db.Media.CountAsync(),
        Recent = await db.Contents.AsNoTracking().Include(x => x.Translations).Where(x => !x.IsDeleted).OrderByDescending(x => x.UpdatedAt).Take(8).ToListAsync()
    });
}
