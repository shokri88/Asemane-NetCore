using Asemane.Web.Models;
namespace Asemane.Web.ViewModels;
public class SeoModel
{
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public string Canonical { get; set; } = "";
    public string Image { get; set; } = "";
    public bool NoIndex { get; set; }
    public string Type { get; set; } = "website";
    public Dictionary<string,string> Alternates { get; set; } = [];
    public string JsonLd { get; set; } = "";
}
public class PublicList
{
    public string Culture { get; set; } = "en";
    public ContentKind Kind { get; set; }
    public List<ContentTranslation> Items { get; set; } = [];
    public List<CategoryTranslation> Categories { get; set; } = [];
    public string? Category { get; set; }
    public int Page { get; set; } = 1;
    public int Pages { get; set; } = 1;
}
public class PublicDetail
{
    public string Culture { get; set; } = "en";
    public ContentTranslation Translation { get; set; } = null!;
    public List<ContentTranslation> Team { get; set; } = [];
    public int TotalProjects { get; set; }
    public int DesignProjects { get; set; }
    public int ConstructionProjects { get; set; }
    public int CompletedProjects { get; set; }
}
public class SiteChrome
{
    public SiteSettings Settings { get; set; } = new();
    public SiteTranslation Translation { get; set; } = new();
    public string Culture { get; set; } = "en";
}
