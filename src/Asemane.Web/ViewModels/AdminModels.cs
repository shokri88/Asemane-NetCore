using System.ComponentModel.DataAnnotations;
using Asemane.Web.Models;
using Microsoft.AspNetCore.Mvc.Rendering;
namespace Asemane.Web.ViewModels;
public class LoginForm
{
    [Required, EmailAddress] public string Email { get; set; } = "";
    [Required, DataType(DataType.Password)] public string Password { get; set; } = "";
    public bool RememberMe { get; set; }
    public string? ReturnUrl { get; set; }
}
public class ContentForm
{
    public int Id { get; set; }
    public ContentKind Kind { get; set; }
    public Guid Version { get; set; }
    public string Culture { get; set; } = "en";
    [Required, MaxLength(180)] public string Title { get; set; } = "";
    [Required, MaxLength(180)] public string Slug { get; set; } = "";
    [MaxLength(500)] public string Summary { get; set; } = "";
    [MaxLength(100000)] public string Body { get; set; } = "";
    public bool BodyIsHtml { get; set; }
    [MaxLength(180)] public string Subtitle { get; set; } = "";
    [MaxLength(180)] public string Location { get; set; } = "";
    [MaxLength(80)] public string ProjectStatus { get; set; } = "";
    [MaxLength(100)] public string AuthorName { get; set; } = "";
    [MaxLength(70)] public string SeoTitle { get; set; } = "";
    [MaxLength(170)] public string MetaDescription { get; set; } = "";
    public bool NoIndex { get; set; }
    public bool Published { get; set; }
    public bool Featured { get; set; }
    [Range(0,99999)] public int SortOrder { get; set; }
    public int? CategoryId { get; set; }
    [Range(0,100000000)] public decimal? Area { get; set; }
    [Range(1000,3000)] public int? Year { get; set; }
    public List<SelectListItem> Categories { get; set; } = [];
}
public class ContentList
{
    public ContentKind Kind { get; set; }
    public string Query { get; set; } = "";
    public string Status { get; set; } = "";
    public string Sort { get; set; } = "updated";
    public int Page { get; set; }
    public int Pages { get; set; }
    public int Total { get; set; }
    public List<ContentItem> Items { get; set; } = [];
}
public class CategoryForm
{
    public int Id { get; set; }
    public ContentKind Kind { get; set; }
    [Required, MaxLength(100)] public string Name { get; set; } = "";
    [Required, MaxLength(120)] public string Slug { get; set; } = "";
    [Range(0,99999)] public int SortOrder { get; set; }
}
public class SettingsForm
{
    [Required, MaxLength(100)] public string AboutTotalTitle { get; set; } = "All Projects";
    [Range(0,1000000000)] public int? AboutTotalValue { get; set; }
    [Required, MaxLength(100)] public string AboutDesignTitle { get; set; } = "Design Development";
    [Range(0,1000000000)] public int? AboutDesignValue { get; set; }
    [Required, MaxLength(100)] public string AboutConstructionTitle { get; set; } = "Under Construction";
    [Range(0,1000000000)] public int? AboutConstructionValue { get; set; }
    [Required, MaxLength(100)] public string AboutCompletedTitle { get; set; } = "Complete";
    [Range(0,1000000000)] public int? AboutCompletedValue { get; set; }

    [Required, MaxLength(150)] public string Brand { get; set; } = "";
    [MaxLength(200)] public string? Phone { get; set; }
    [MaxLength(30)] public string PostalCode { get; set; } = "";
    [MaxLength(2000)] public string MapEmbedUrl { get; set; } = "";
    [MaxLength(150), EmailAddress] public string? Email { get; set; }
    [MaxLength(500), Url] public string? InstagramUrl { get; set; }
    [Range(-90,90)] public decimal? Latitude { get; set; }
    [Range(-180,180)] public decimal? Longitude { get; set; }
    [Required, MaxLength(70)] public string HomeTitle { get; set; } = "";
    [MaxLength(170)] public string HomeDescription { get; set; } = "";
    [MaxLength(500)] public string Address { get; set; } = "";
    [Range(0,99999)] public int CompletedProjects { get; set; }
    [Range(0,200)] public int YearsExperience { get; set; }
    [Range(0,9999)] public int TeamCount { get; set; }
    public int? LogoId { get; set; }
    public IFormFile? Logo { get; set; }
}
public class MediaForm
{
    public int Id { get; set; }
    public int ContentId { get; set; }
    [Required, MaxLength(250)] public string Alt { get; set; } = "";
    [MaxLength(300)] public string Caption { get; set; } = "";
    [Range(0,99999)] public int SortOrder { get; set; }
    [EnumDataType(typeof(ImageRole))] public ImageRole Role { get; set; }
}
public class UserForm
{
    [Required,EmailAddress] public string Email { get; set; } = "";
    [Required,MaxLength(100)] public string DisplayName { get; set; } = "";
    [Required,MinLength(12),DataType(DataType.Password)] public string Password { get; set; } = "";
    [Required] public string Role { get; set; } = "Editor";
}
public class ResetPasswordForm
{
    [Required] public string Id { get; set; } = "";
    [Required,MinLength(12),DataType(DataType.Password)] public string Password { get; set; } = "";
}
public class DashboardModel
{
    public int Projects { get; set; }
    public int Articles { get; set; }
    public int Drafts { get; set; }
    public int Images { get; set; }
    public List<ContentItem> Recent { get; set; } = [];
}
