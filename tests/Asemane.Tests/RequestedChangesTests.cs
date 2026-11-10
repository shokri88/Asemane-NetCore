using System.Net;
using System.Text.RegularExpressions;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace Asemane.Tests;

public class RequestedChangesTests : IAsyncLifetime
{
    private readonly CmsFactory factory = new();
    private HttpClient client = null!;
    public async Task InitializeAsync()
    {
        await factory.SeedAsync();
        client = factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
    }
    public Task DisposeAsync() { client.Dispose(); factory.Dispose(); return Task.CompletedTask; }
    private static string Token(string html) => Regex.Match(html,"name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"").Groups[1].Value;
    private async Task Login()
    {
        var html = await client.GetStringAsync("/admin/account/login");
        var response = await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string> { ["Email"] = CmsFactory.AdminEmail, ["Password"] = CmsFactory.Password, ["__RequestVerificationToken"] = Token(html) }));
        Assert.Equal(HttpStatusCode.Redirect,response.StatusCode);
    }
    private static ContentItem NewProject(string slug, Category? category = null) => new()
    {
        Kind = ContentKind.Project, Category = category,
        Translations = [new ContentTranslation { Kind = ContentKind.Project, Title = slug, Slug = slug, Body = "Published body", Published = true, PublishedAt = DateTimeOffset.UtcNow.AddDays(-1) }]
    };
    private static string Header(string html) => Regex.Match(html,"<header class=\"prague-header[\\s\\S]*?</header>").Value;

    [Fact] public async Task AllPublicSectionsShareTheSameFiveItemNavigation()
    {
        var expected = Header(await client.GetStringAsync("/en"));
        Assert.NotEmpty(expected); Assert.DoesNotContain("Project Details",expected);
        Assert.Equal(5,Regex.Matches(expected,"class=\"menu-item ").Count);
        foreach (var path in new[] { "/en/about", "/en/contact", "/en/projects", "/en/projects/garden-house", "/en/journal", "/en/journal/studio-news" })
            Assert.Equal(expected,Header(await client.GetStringAsync(path)));
    }

    [Fact] public async Task ProjectImageRolesAreIndependentAndOnlyGalleryImagesEnterSlider()
    {
        using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var project = await db.Contents.SingleAsync(x => x.Kind == ContentKind.Project && x.Featured && x.Translations.Any(t => t.Slug == "garden-house"));
        foreach (var role in new[] { ImageRole.HomeFirst, ImageRole.HomeSecond, ImageRole.ProjectCard, ImageRole.ProjectBanner, ImageRole.ProjectGallery, ImageRole.ProjectGallery })
            project.Images.Add(new MediaAsset { Role = role, StoredName = Guid.NewGuid()+".png", Translations = [new MediaTranslation { Alt = "Role "+role }] });
        await db.SaveChangesAsync();
        string Source(ImageRole role) => "src=\"/media/"+project.Images.First(x => x.Role == role).Id+"\"";
        var home = await client.GetStringAsync("/en");
        Assert.Contains(Source(ImageRole.HomeFirst),home); Assert.Contains(Source(ImageRole.HomeSecond),home);
        Assert.DoesNotContain(Source(ImageRole.ProjectCard),home); Assert.DoesNotContain(Source(ImageRole.ProjectBanner),home);
        var grid = await client.GetStringAsync("/en/projects");
        Assert.Contains(Source(ImageRole.ProjectCard),grid); Assert.DoesNotContain(Source(ImageRole.HomeFirst),grid);
        var detail = await client.GetStringAsync("/en/projects/garden-house");
        Assert.Contains(Source(ImageRole.ProjectBanner),detail); Assert.DoesNotContain(Source(ImageRole.ProjectCard),detail);
        var slides = Regex.Match(detail,"id=\"slides\">([\\s\\S]*?)</div>\\s*</div>\\s*</div>").Value;
        Assert.Equal(2,Regex.Matches(slides,"class=\"swiper-slide\"").Count);
        foreach (var image in project.Images.Where(x => x.Role == ImageRole.ProjectGallery)) Assert.Contains("src=\"/media/"+image.Id+"\"",slides);
        Assert.DoesNotContain(Source(ImageRole.ProjectBanner),slides);
    }

    [Fact] public async Task MediaFormsEnforceSingleSlotsAndAllowSeveralGalleryImages()
    {
        await Login(); using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var id = await db.Contents.Where(x => x.Translations.Any(t => t.Slug == "garden-house")).Select(x => x.Id).SingleAsync();
        async Task<HttpResponseMessage> Upload(ImageRole role)
        {
            var html = await client.GetStringAsync("/admin/media?contentId="+id);
            using var body = new MultipartFormDataContent();
            body.Add(new StringContent(Token(html)),"__RequestVerificationToken");body.Add(new StringContent(id.ToString()),"contentId");
            body.Add(new StringContent(((int)role).ToString()),"role");body.Add(new StringContent("Role image"),"alt");
            body.Add(new ByteArrayContent(Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII=")),"file","test.png");
            return await client.PostAsync("/admin/media/upload",body);
        }
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.HomeFirst)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.HomeFirst)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.ProjectGallery)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.ProjectGallery)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,(await Upload((ImageRole)999)).StatusCode);
        Assert.Equal(3,await db.Media.CountAsync()); Assert.Equal(3,Directory.GetFiles(Path.Combine(factory.Root,"uploads")).Length);
        var gallery = await db.Media.FirstAsync(x => x.Role == ImageRole.ProjectGallery);
        var edit = await client.GetStringAsync("/admin/media?contentId="+id);
        await client.PostAsync("/admin/media/update",new FormUrlEncodedContent(new Dictionary<string,string> { ["Id"] = gallery.Id.ToString(), ["ContentId"] = id.ToString(), ["Alt"] = "New alt", ["Role"] = "HomeFirst", ["__RequestVerificationToken"] = Token(edit) }));
        db.ChangeTracker.Clear(); Assert.Equal(ImageRole.ProjectGallery,(await db.Media.FindAsync(gallery.Id))!.Role);
    }

    [Fact] public async Task CategoryFilterCoversAllPublishedProjectsAndKeepsCategoryInPagination()
    {
        using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var category = new Category { Kind = ContentKind.Project, Translations = [new CategoryTranslation { Kind = ContentKind.Project, Slug = "villas", Name = "Villas" }] };
        for (var i = 0; i < 14; i++) db.Contents.Add(NewProject("villa-"+i,category));
        await db.SaveChangesAsync();
        var page1 = await client.GetStringAsync("/en/projects?category=villas");
        Assert.DoesNotContain("garden-house",page1);
        Assert.Equal(12,Regex.Matches(page1,"class=\"project-grid-item-title\"").Count);
        Assert.Contains("data-url=\"/en/projects?category=villas\"",page1);
        Assert.Contains("page=2&amp;category=villas",page1);
        var page2 = await client.GetStringAsync("/en/projects?category=villas&page=2");
        Assert.Equal(2,Regex.Matches(page2,"class=\"project-grid-item-title\"").Count);
        Assert.Equal(HttpStatusCode.NotFound,(await client.GetAsync("/en/projects?category=missing")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,(await client.GetAsync("/en/projects?category=villas&page=3")).StatusCode);
    }

    [Fact] public async Task ContactSettingsPersistAndOriginalGoogleMapIsTheDefault()
    {
        var original = WebUtility.HtmlDecode(await client.GetStringAsync("/en/contact")); Assert.Contains(ContactMap.OriginalEmbedUrl,original);
        await Login(); var html = await client.GetStringAsync("/admin/settings");
        var form = new Dictionary<string,string> { ["Brand"] = "Test studio", ["HomeTitle"] = "Home", ["Address"] = "New studio address", ["Phone"] = "07111111111;09111111111", ["Email"] = "studio@example.test", ["PostalCode"] = "71868-00000", ["MapEmbedUrl"] = "https://www.google.com/maps/embed?pb=test", ["__RequestVerificationToken"] = Token(html) };
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/settings",new FormUrlEncodedContent(form))).StatusCode);
        html = await client.GetStringAsync("/en/contact"); Assert.Contains("New studio address",html); Assert.Contains("tel:09111111111",html); Assert.Contains("71868-00000",html); Assert.Contains("studio@example.test",html); Assert.Contains(form["MapEmbedUrl"],html);
        form["MapEmbedUrl"] = "https://www.google.com.evil.test/maps/embed";
        Assert.Equal(HttpStatusCode.OK,(await client.PostAsync("/admin/settings",new FormUrlEncodedContent(form))).StatusCode);
        Assert.DoesNotContain("evil.test",await client.GetStringAsync("/en/contact"));
    }

    [Fact] public async Task HtmlEditorSavesFormattedContentSafelyAndFeaturedCanBeDisabled()
    {
        await Login(); using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var item = await db.Contents.SingleAsync(x => x.Translations.Any(t => t.Slug == "garden-house"));
        var html = await client.GetStringAsync("/admin/content/edit/"+item.Id);
        Assert.Contains("summernote-lite.min.js",html); Assert.Contains("&lt;p&gt;First paragraph.",html);
        var form = new Dictionary<string,string> { ["Id"] = item.Id.ToString(), ["Kind"] = "Project", ["Version"] = item.Version.ToString(), ["Culture"] = "en", ["Title"] = "Formatted project", ["Slug"] = "garden-house", ["BodyIsHtml"] = "true", ["Body"] = "<h2>Design story</h2><p><strong>Bold</strong> <a href=\"https://example.test\">Link</a></p><table><tr><td>Cell</td></tr></table><script>alert(1)</script><iframe src=\"https://evil.test\"></iframe><a href=\"javascript:alert(1)\" onclick=\"alert(1)\">Bad</a>", ["MetaDescription"] = "Description", ["Published"] = "true", ["Featured"] = "false", ["__RequestVerificationToken"] = Token(html) };
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/content/edit",new FormUrlEncodedContent(form))).StatusCode);
        html = await client.GetStringAsync("/en/projects/garden-house"); Assert.Contains("<h2>Design story</h2>",html); Assert.Contains("<strong>Bold</strong>",html); Assert.Contains("<td>Cell</td>",html); Assert.DoesNotContain("javascript:",html); Assert.DoesNotContain("onclick=",html); Assert.DoesNotContain("evil.test",html); Assert.DoesNotContain("alert(1)",html);
        Assert.DoesNotContain("garden-house",await client.GetStringAsync("/en"));
        db.ChangeTracker.Clear(); Assert.True((await db.ContentTranslations.SingleAsync(x => x.ContentItemId == item.Id)).BodyIsHtml);
        // بازگشت فرم نامعتبر نیز نباید HTML خام را دوباره به Summernote بدهد.
        form["Title"] = ""; form["Body"] = "<p>Safe</p><img src=x onerror=alert(2)>";
        html = await (await client.PostAsync("/admin/content/edit",new FormUrlEncodedContent(form))).Content.ReadAsStringAsync();
        var textarea = WebUtility.HtmlDecode(Regex.Match(html,"<textarea[^>]*id=\"Body\"[\\s\\S]*?</textarea>").Value);
        Assert.DoesNotContain("onerror",textarea); Assert.Contains("Safe",textarea);
    }

    [Theory]
    [InlineData("<svg><a onload=alert(1)>x</a></svg>")]
    [InlineData("<a href=\"jav&#x61;script:alert(1)\">click</a>")]
    [InlineData("<p style=\"background-image:url(javascript:alert(1));position:fixed\" onclick=\"alert(1)\">text</p>")]
    [InlineData("<math><mtext><img src=x onerror=alert(1)></mtext></math>")]
    public void HtmlSanitizerRemovesActiveMarkupAndUnsafeStyles(string input)
    {
        var clean = RichText.Sanitize(input);
        foreach (var forbidden in new[] { "<svg", "<math", "<img", "onload", "onerror", "onclick", "javascript:", "position:", "background-image:" }) Assert.DoesNotContain(forbidden,clean,StringComparison.OrdinalIgnoreCase);
        Assert.False(RichText.HasText("<p><br></p>",true));
        Assert.False(RichText.HasText("<p>&nbsp;</p>",true));
    }
}
