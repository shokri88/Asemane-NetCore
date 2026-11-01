using Asemane.Web.Data;
using Asemane.Web.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
namespace Asemane.Tests;
public class CmsFactory : WebApplicationFactory<Program>
{
    public string Root { get; } = Path.Combine(Path.GetTempPath(),"asemane-test-"+Guid.NewGuid().ToString("N"));
    public const string AdminEmail = "admin@example.test";
    public const string EditorEmail = "editor@example.test";
    public const string Password = "Test-Only-Password!123";
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        Directory.CreateDirectory(Root);
        builder.UseEnvironment("Development");
        builder.ConfigureAppConfiguration((_,config) => config.AddInMemoryCollection(new Dictionary<string,string?> { ["Site:BaseUrl"] = "https://studio.test", ["Site:IndexingEnabled"] = "true", ["Storage:RootPath"] = Path.Combine(Root,"uploads"), ["AllowedHosts"] = "*" }));
        builder.ConfigureServices(services =>
        {
            // SQLite فقط برای آزمون قابل‌حمل است؛ برنامه اصلی همیشه SQL Server دارد.
            services.AddScoped<AppDbContext>(_ => new TestDbContext(new DbContextOptionsBuilder<AppDbContext>().UseSqlite("Data Source="+Path.Combine(Root,"test.db")).Options));
            services.Configure<Microsoft.Extensions.Logging.LoggerFilterOptions>(o => o.MinLevel = Microsoft.Extensions.Logging.LogLevel.Error);
        });
    }
    public async Task SeedAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.EnsureCreatedAsync();
        if (await db.Settings.AnyAsync()) return;
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
        foreach (var role in new[] { "Admin", "Editor" }) await roles.CreateAsync(new IdentityRole(role));
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        foreach (var pair in new[] { (AdminEmail,"Admin"),(EditorEmail,"Editor") })
        { var user = new ApplicationUser { UserName = pair.Item1, Email = pair.Item1, DisplayName = pair.Item2 }; var result = await users.CreateAsync(user,Password); if (!result.Succeeded) throw new Exception(string.Join(",",result.Errors.Select(x => x.Description))); await users.AddToRoleAsync(user,pair.Item2); }
        db.Settings.Add(new SiteSettings { Brand = "Test studio", Translations = [new SiteTranslation { HomeDescription = "Test description", Address = "Shiraz" }] });
        foreach (var entry in new[] { (ContentKind.Project,"garden-house",true),(ContentKind.Project,"secret-project",false),(ContentKind.Article,"studio-news",true),(ContentKind.Page,"about",true),(ContentKind.Page,"contact",true) })
            db.Contents.Add(new ContentItem { Kind = entry.Item1, Key = entry.Item1 == ContentKind.Page ? entry.Item2 : "", Featured = true, Translations = [new ContentTranslation { Kind = entry.Item1, Title = entry.Item2, Slug = entry.Item2, Body = "First paragraph.\n\nSecond paragraph.", MetaDescription = "Description", Published = entry.Item3, PublishedAt = entry.Item3 ? DateTimeOffset.UtcNow.AddDays(-1) : null }] });
        await db.SaveChangesAsync();
    }
    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing) { Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools(); try { Directory.Delete(Root,true); } catch (IOException) { } }
    }
    private class TestDbContext(DbContextOptions<AppDbContext> options) : AppDbContext(options)
    {
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            foreach (var property in builder.Model.GetEntityTypes().SelectMany(x => x.GetProperties()).Where(x => x.ClrType == typeof(DateTimeOffset) || x.ClrType == typeof(DateTimeOffset?))) property.SetValueConverter(new DateTimeOffsetToBinaryConverter());
        }
    }
}
