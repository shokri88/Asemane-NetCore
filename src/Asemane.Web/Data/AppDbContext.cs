using Asemane.Web.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
namespace Asemane.Web.Data;
public class AppDbContext(DbContextOptions<AppDbContext> options) : IdentityDbContext<ApplicationUser>(options)
{
    public DbSet<ContentItem> Contents => Set<ContentItem>();
    public DbSet<ContentTranslation> ContentTranslations => Set<ContentTranslation>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<CategoryTranslation> CategoryTranslations => Set<CategoryTranslation>();
    public DbSet<MediaAsset> Media => Set<MediaAsset>();
    public DbSet<MediaTranslation> MediaTranslations => Set<MediaTranslation>();
    public DbSet<SiteSettings> Settings => Set<SiteSettings>();
    public DbSet<SlugRedirect> Redirects => Set<SlugRedirect>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        base.OnModelCreating(b);
        b.Entity<ContentItem>().Property(x => x.Area).HasPrecision(12, 2);
        b.Entity<ContentItem>().Property(x => x.Version).IsConcurrencyToken();
        b.Entity<ContentItem>().HasOne(x => x.Category).WithMany().OnDelete(DeleteBehavior.Restrict);
        b.Entity<ContentTranslation>().HasIndex(x => new { x.ContentItemId, x.Culture }).IsUnique();
        b.Entity<ContentTranslation>().HasIndex(x => new { x.Kind, x.Culture, x.Slug }).IsUnique();
        b.Entity<CategoryTranslation>().HasIndex(x => new { x.CategoryId, x.Culture }).IsUnique();
        b.Entity<CategoryTranslation>().HasIndex(x => new { x.Kind, x.Culture, x.Slug }).IsUnique();
        b.Entity<MediaTranslation>().HasIndex(x => new { x.MediaAssetId, x.Culture }).IsUnique();
        b.Entity<MediaAsset>().HasOne(x => x.ContentItem).WithMany(x => x.Images).OnDelete(DeleteBehavior.Restrict);
        // جایگاه‌های تکی پروژه یکتا هستند؛ گالری و تصاویر قدیمی چندتایی می‌مانند.
        b.Entity<MediaAsset>().HasIndex(x => x.ContentItemId);
        b.Entity<MediaAsset>().HasIndex(x => new { x.ContentItemId, x.Role }).IsUnique()
            .HasFilter("[ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,8)");
        b.Entity<SiteTranslation>().Property(x => x.AboutTotalTitle).HasDefaultValue("All Projects");
        b.Entity<SiteTranslation>().Property(x => x.AboutDesignTitle).HasDefaultValue("Design Development");
        b.Entity<SiteTranslation>().Property(x => x.AboutConstructionTitle).HasDefaultValue("Under Construction");
        b.Entity<SiteTranslation>().Property(x => x.AboutCompletedTitle).HasDefaultValue("Complete");
        b.Entity<SiteTranslation>().HasIndex(x => new { x.SiteSettingsId, x.Culture }).IsUnique();
        b.Entity<SiteSettings>().Property(x => x.Latitude).HasPrecision(9, 6);
        b.Entity<SiteSettings>().Property(x => x.Longitude).HasPrecision(9, 6);
        b.Entity<SlugRedirect>().HasIndex(x => new { x.Kind, x.Culture, x.OldSlug }).IsUnique();
        b.Entity<SlugRedirect>().HasOne(x => x.ContentItem).WithMany().OnDelete(DeleteBehavior.Restrict);
        b.Entity<ContentItem>().HasIndex(x => new { x.Kind, x.IsDeleted, x.SortOrder });
    }
}
