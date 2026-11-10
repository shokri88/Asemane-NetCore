using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;
namespace Asemane.Web.Models;

public enum ContentKind { Project = 1, Article = 2, Page = 3, Team = 4 }
public enum ImageRole { General = 0, HomeFirst = 1, HomeSecond = 2, ProjectCard = 3, ProjectBanner = 4, ProjectGallery = 5 }
public class ApplicationUser : IdentityUser { [MaxLength(100)] public string DisplayName { get; set; } = ""; }
public class ContentItem
{
    public int Id { get; set; }
    public ContentKind Kind { get; set; }
    [MaxLength(80)] public string Key { get; set; } = "";
    public int? CategoryId { get; set; }
    public Category? Category { get; set; }
    public bool IsDeleted { get; set; }
    public bool Featured { get; set; }
    public int SortOrder { get; set; }
    public decimal? Area { get; set; }
    public int? Year { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
    // یک توکن ساده برای جلوگیری از بازنویسی ناخواسته تغییرات ویرایشگر دیگر.
    public Guid Version { get; set; } = Guid.NewGuid();
    public List<ContentTranslation> Translations { get; set; } = [];
    public List<MediaAsset> Images { get; set; } = [];
}
public class ContentTranslation
{
    public int Id { get; set; }
    public int ContentItemId { get; set; }
    public ContentItem ContentItem { get; set; } = null!;
    [MaxLength(10)] public string Culture { get; set; } = "en";
    public ContentKind Kind { get; set; }
    [MaxLength(180)] public string Title { get; set; } = "";
    [MaxLength(180)] public string Slug { get; set; } = "";
    [MaxLength(500)] public string Summary { get; set; } = "";
    public string Body { get; set; } = "";
    public bool BodyIsHtml { get; set; }
    [MaxLength(180)] public string Subtitle { get; set; } = "";
    [MaxLength(180)] public string Location { get; set; } = "";
    [MaxLength(80)] public string ProjectStatus { get; set; } = "";
    [MaxLength(100)] public string AuthorName { get; set; } = "";
    [MaxLength(70)] public string SeoTitle { get; set; } = "";
    [MaxLength(170)] public string MetaDescription { get; set; } = "";
    public bool NoIndex { get; set; }
    public bool Published { get; set; }
    public DateTimeOffset? PublishedAt { get; set; }
}
public class Category
{
    public int Id { get; set; }
    public ContentKind Kind { get; set; }
    public int SortOrder { get; set; }
    public List<CategoryTranslation> Translations { get; set; } = [];
}
public class CategoryTranslation
{
    public ContentKind Kind { get; set; }
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;
    [MaxLength(10)] public string Culture { get; set; } = "en";
    [MaxLength(100)] public string Name { get; set; } = "";
    [MaxLength(120)] public string Slug { get; set; } = "";
}
public class MediaAsset
{
    public int Id { get; set; }
    public int? ContentItemId { get; set; }
    public ContentItem? ContentItem { get; set; }
    [MaxLength(100)] public string StoredName { get; set; } = "";
    [MaxLength(250)] public string OriginalName { get; set; } = "";
    [MaxLength(50)] public string ContentType { get; set; } = "";
    public long Bytes { get; set; }
    public bool IsCover { get; set; }
    public ImageRole Role { get; set; }
    public int SortOrder { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public List<MediaTranslation> Translations { get; set; } = [];
}
public class MediaTranslation
{
    public int Id { get; set; }
    public int MediaAssetId { get; set; }
    public MediaAsset MediaAsset { get; set; } = null!;
    [MaxLength(10)] public string Culture { get; set; } = "en";
    [MaxLength(250)] public string Alt { get; set; } = "";
    [MaxLength(300)] public string Caption { get; set; } = "";
}
public class SiteSettings
{
    public int Id { get; set; } = 1;
    [MaxLength(150)] public string Brand { get; set; } = "Asmane Architectural Studio";
    [MaxLength(200)] public string Phone { get; set; } = "";
    [MaxLength(30)] public string PostalCode { get; set; } = "";
    [MaxLength(2000)] public string MapEmbedUrl { get; set; } = "";
    [MaxLength(150)] public string Email { get; set; } = "";
    [MaxLength(500)] public string InstagramUrl { get; set; } = "";
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int? LogoId { get; set; }
    public int CompletedProjects { get; set; }
    public int YearsExperience { get; set; }
    public int TeamCount { get; set; }
    public List<SiteTranslation> Translations { get; set; } = [];
}
public class SiteTranslation
{
    public int Id { get; set; }
    public int SiteSettingsId { get; set; }
    public SiteSettings SiteSettings { get; set; } = null!;
    [MaxLength(10)] public string Culture { get; set; } = "en";
    [MaxLength(70)] public string HomeTitle { get; set; } = "Architecture and Interior Design";
    [MaxLength(170)] public string HomeDescription { get; set; } = "";
    [MaxLength(500)] public string Address { get; set; } = "";
}
public class SlugRedirect
{
    public int Id { get; set; }
    public ContentKind Kind { get; set; }
    [MaxLength(10)] public string Culture { get; set; } = "en";
    [MaxLength(180)] public string OldSlug { get; set; } = "";
    public int ContentItemId { get; set; }
    public ContentItem ContentItem { get; set; } = null!;
}
