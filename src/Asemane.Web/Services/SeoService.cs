using System.Text.Json;
using Asemane.Web.Models;
using Asemane.Web.ViewModels;
namespace Asemane.Web.Services;
public class SeoService(IConfiguration config)
{
    public bool IndexingEnabled => config.GetValue<bool>("Site:IndexingEnabled") && !BaseUrl.Contains("example.com",StringComparison.OrdinalIgnoreCase);
    public string BaseUrl
    {
        get
        {
            var raw = config["Site:BaseUrl"] ?? "https://example.com";
            if (!Uri.TryCreate(raw,UriKind.Absolute,out var uri) || uri.Scheme is not ("http" or "https") || uri.AbsolutePath != "/" || !string.IsNullOrEmpty(uri.Query) || !string.IsNullOrEmpty(uri.Fragment)) throw new InvalidOperationException("Site:BaseUrl must be an absolute origin without path/query.");
            return raw.TrimEnd('/');
        }
    }
    public string Absolute(string path) => BaseUrl + (path.StartsWith('/') ? path : "/" + path);
    public SeoModel Page(string title, string description, string path, SiteChrome chrome)
    {
        var organization = new Dictionary<string,object?> { ["@type"] = "Organization", ["@id"] = BaseUrl + "/#organization", ["name"] = chrome.Settings.Brand, ["url"] = BaseUrl };
        if (chrome.Settings.LogoId.HasValue) organization["logo"] = Absolute("/media/"+chrome.Settings.LogoId);
        if (chrome.Settings.Phone != "") organization["telephone"] = chrome.Settings.Phone;
        if (chrome.Settings.Email != "") organization["email"] = chrome.Settings.Email;
        if (chrome.Settings.InstagramUrl != "") organization["sameAs"] = new[] { chrome.Settings.InstagramUrl };
        return new SeoModel { Title = title, Description = description, Canonical = Absolute(path), NoIndex = !IndexingEnabled, Image = chrome.Settings.LogoId.HasValue ? Absolute("/media/"+chrome.Settings.LogoId) : "", JsonLd = JsonSerializer.Serialize(new Dictionary<string,object> { ["@context"] = "https://schema.org", ["@graph"] = new object[] { organization, new Dictionary<string,object> { ["@type"] = "WebSite", ["@id"] = BaseUrl + "/#website", ["url"] = BaseUrl, ["name"] = chrome.Settings.Brand } } }) };
    }
    public SeoModel Detail(ContentTranslation t, SiteChrome chrome)
    {
        var path = Slugs.Path(t.Kind,t.Culture,t.Slug);
        var seo = Page(t.SeoTitle.Length > 0 ? t.SeoTitle : t.Title,t.MetaDescription.Length > 0 ? t.MetaDescription : t.Summary,path,chrome);
        seo.NoIndex |= t.NoIndex;
        var cover = t.Kind == ContentKind.Project ? SiteService.ProjectImage(t.ContentItem,ImageRole.ProjectBanner) ?? SiteService.ProjectImage(t.ContentItem,ImageRole.ProjectCard) : SiteService.Cover(t.ContentItem);
        if (cover is not null) seo.Image = Absolute("/media/"+cover.Id);
        var schema = new Dictionary<string,object?>
        {
            ["@type"] = t.Kind == ContentKind.Article ? "Article" : "WebPage", ["@id"] = seo.Canonical + "#content", ["url"] = seo.Canonical, ["name"] = t.Title, ["description"] = seo.Description, ["inLanguage"] = t.Culture,
            ["datePublished"] = t.PublishedAt?.ToString("O"), ["dateModified"] = t.ContentItem.UpdatedAt.ToString("O")
        };
        if (seo.Image != "") schema["image"] = seo.Image;
        if (t.Kind == ContentKind.Article)
        {
            seo.Type = "article"; schema["headline"] = t.Title;
            schema["author"] = t.AuthorName.Length > 0 ? new Dictionary<string,object> { ["@type"] = "Person", ["name"] = t.AuthorName } : new Dictionary<string,object> { ["@type"] = "Organization", ["name"] = chrome.Settings.Brand };
            schema["publisher"] = new Dictionary<string,object> { ["@id"] = BaseUrl + "/#organization" };
        }
        var graph = new List<object> { schema };
        graph.Add(new Dictionary<string,object> { ["@type"] = "BreadcrumbList", ["itemListElement"] = new object[] {
            new Dictionary<string,object> { ["@type"] = "ListItem", ["position"] = 1, ["name"] = "Home", ["item"] = Absolute("/"+t.Culture) },
            new Dictionary<string,object> { ["@type"] = "ListItem", ["position"] = 2, ["name"] = t.Title, ["item"] = seo.Canonical }
        } });
        // سازمان با @id مشخص نیز در همین گراف تعریف می‌شود تا ارجاع ناشناخته نباشد.
        graph.Add(new Dictionary<string,object> { ["@type"] = "Organization", ["@id"] = BaseUrl + "/#organization", ["name"] = chrome.Settings.Brand, ["url"] = BaseUrl });
        seo.JsonLd = JsonSerializer.Serialize(new Dictionary<string,object> { ["@context"] = "https://schema.org", ["@graph"] = graph });
        return seo;
    }
}
