using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace Asemane.Tests;
public class CmsTests : IAsyncLifetime
{
    private readonly CmsFactory factory = new();
    private HttpClient client = null!;
    public async Task InitializeAsync() { await factory.SeedAsync(); client = factory.CreateClient(new Microsoft.AspNetCore.Mvc.Testing.WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false }); }
    public Task DisposeAsync() { client.Dispose(); factory.Dispose(); return Task.CompletedTask; }
    private static string Token(string html) => Regex.Match(html,"name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"").Groups[1].Value;
    private async Task Login(string email = CmsFactory.AdminEmail)
    {
        var html = await client.GetStringAsync("/admin/account/login");
        var response = await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string> { ["Email"] = email, ["Password"] = CmsFactory.Password, ["__RequestVerificationToken"] = Token(html) }));
        Assert.Equal(HttpStatusCode.Redirect,response.StatusCode);
    }
    [Fact] public async Task DraftAndDisabledLanguageAreNotPublic()
    {
        Assert.Equal(HttpStatusCode.NotFound,(await client.GetAsync("/en/projects/secret-project")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,(await client.GetAsync("/fa")).StatusCode);
        var html = await client.GetStringAsync("/en"); Assert.Contains("garden-house",html); Assert.DoesNotContain("secret-project",html);
    }
    [Fact] public async Task SeoAndSitemapUseConfiguredOriginAndOnlyPublishedContent()
    {
        var detail = await client.GetAsync("/en/projects/garden-house"); var html = await detail.Content.ReadAsStringAsync(); Assert.True(detail.IsSuccessStatusCode, html);
        Assert.Contains("https://studio.test/en/projects/garden-house",html); Assert.Contains("application/ld+json",WebUtility.HtmlDecode(html)); Assert.Contains("hreflang=\"en\"",html); Assert.DoesNotContain("hreflang=\"fa\"",html);
        var sitemap = await client.GetStringAsync("/sitemap.xml"); Assert.Contains("garden-house",sitemap); Assert.DoesNotContain("secret-project",sitemap); Assert.DoesNotContain("/fa",sitemap);
    }
    [Fact] public async Task AnonymousAdminIsRedirectedAndCsrfIsEnforced()
    {
        Assert.Equal(HttpStatusCode.Redirect,(await client.GetAsync("/admin")).StatusCode);
        var response = await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string> { ["Email"] = CmsFactory.AdminEmail, ["Password"] = CmsFactory.Password }));
        Assert.Equal(HttpStatusCode.BadRequest,response.StatusCode);
    }
    [Fact] public async Task EditorCannotManageSettingsOrUsers()
    {
        await Login(CmsFactory.EditorEmail);
        Assert.Equal(HttpStatusCode.OK,(await client.GetAsync("/admin/content")).StatusCode);
        foreach (var path in new[] { "/admin/users", "/admin/settings" }) { var result = await client.GetAsync(path); Assert.Equal(HttpStatusCode.Redirect,result.StatusCode); Assert.Contains("denied",result.Headers.Location!.ToString(),StringComparison.OrdinalIgnoreCase); }
    }
    [Fact] public async Task ContentEditPersistsAndRedirectsOldSlug()
    {
        await Login(); using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var item = await db.Contents.SingleAsync(x => x.Kind == ContentKind.Project && x.Translations.Any(t => t.Slug == "garden-house"));
        var html = await client.GetStringAsync("/admin/content/edit/"+item.Id);
        var form = new Dictionary<string,string> { ["Id"] = item.Id.ToString(), ["Kind"] = "Project", ["Culture"] = "en", ["Version"] = item.Version.ToString(), ["Title"] = "New garden", ["Slug"] = "new-garden", ["Body"] = "Text <script>alert(1)</script>", ["MetaDescription"] = "Meta", ["Published"] = "true", ["SeoTitle"] = "", ["__RequestVerificationToken"] = Token(html) };
        var response = await client.PostAsync("/admin/content/edit",new FormUrlEncodedContent(form));
        Assert.True(response.StatusCode == HttpStatusCode.Redirect, await response.Content.ReadAsStringAsync());
        var old = await client.GetAsync("/en/projects/garden-house"); Assert.Equal(HttpStatusCode.MovedPermanently,old.StatusCode); Assert.Equal("/en/projects/new-garden",old.Headers.Location!.ToString());
        var updated = await client.GetStringAsync("/en/projects/new-garden"); Assert.Contains("&lt;script&gt;",updated); Assert.DoesNotContain("<script>alert",updated);
        // همان فرم قبلی توکن نسخه کهنه دارد و نباید محتوای جدید را بازنویسی کند.
        form["Title"] = "Stale overwrite"; response = await client.PostAsync("/admin/content/edit",new FormUrlEncodedContent(form));
        Assert.Equal(HttpStatusCode.OK,response.StatusCode); Assert.Contains("New garden",await client.GetStringAsync("/en/projects/new-garden"));
    }
    [Fact] public async Task UploadChecksActualTypeAndDraftMediaIsPrivate()
    {
        await Login(); using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var item = await db.Contents.SingleAsync(x => x.Translations.Any(t => t.Slug == "secret-project"));
        var html = await client.GetStringAsync("/admin/media?contentId="+item.Id);
        using var body = new MultipartFormDataContent();
        body.Add(new StringContent(Token(html)),"__RequestVerificationToken"); body.Add(new StringContent(item.Id.ToString()),"contentId"); body.Add(new StringContent("ProjectGallery"),"role"); body.Add(new StringContent("Test image"),"alt");
        body.Add(new ByteArrayContent(Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII=")),"file","safe.png");
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/media/upload",body)).StatusCode);
        var asset = await db.Media.SingleAsync(x => x.ContentItemId == item.Id);
        Assert.True(File.Exists(Path.Combine(factory.Root,"uploads",asset.StoredName)));
        Assert.Equal(HttpStatusCode.OK,(await client.GetAsync("/media/"+asset.Id)).StatusCode);
        using var anonymous = factory.CreateClient(new Microsoft.AspNetCore.Mvc.Testing.WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        Assert.Equal(HttpStatusCode.NotFound,(await anonymous.GetAsync("/media/"+asset.Id)).StatusCode);
        using var badBody = new MultipartFormDataContent(); badBody.Add(new StringContent(Token(html)),"__RequestVerificationToken"); badBody.Add(new StringContent(item.Id.ToString()),"contentId"); badBody.Add(new StringContent("ProjectGallery"),"role"); badBody.Add(new StringContent("Bad image"),"alt"); badBody.Add(new ByteArrayContent(Encoding.UTF8.GetBytes("<script>bad</script>")),"file","fake.png");
        await client.PostAsync("/admin/media/upload",badBody); Assert.Equal(1,await db.Media.CountAsync());
    }
    [Fact] public async Task AdminViewsRenderAndDeletedContentIsNotPublic()
    {
        await Login(); foreach (var path in new[] { "/admin", "/admin/content", "/admin/content/edit", "/admin/categories", "/admin/categories/edit", "/admin/settings", "/admin/users", "/admin/users/create" }) Assert.Equal(HttpStatusCode.OK,(await client.GetAsync(path)).StatusCode);
        using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>(); var item = await db.Contents.SingleAsync(x => x.Translations.Any(t => t.Slug == "garden-house"));
        var html = await client.GetStringAsync("/admin/content");
        var response = await client.PostAsync("/admin/content/delete",new FormUrlEncodedContent(new Dictionary<string,string> { ["id"] = item.Id.ToString(), ["version"] = item.Version.ToString(), ["__RequestVerificationToken"] = Token(html) }));
        Assert.Equal(HttpStatusCode.Redirect,response.StatusCode); Assert.Equal(HttpStatusCode.NotFound,(await client.GetAsync("/en/projects/garden-house")).StatusCode);
    }

    [Fact] public async Task CategoriesAndSettingsSaveThroughRealForms()
    {
        await Login();
        var html = await client.GetStringAsync("/admin/categories/edit");
        var categoryForm = new Dictionary<string,string> { ["Id"] = "0", ["Kind"] = "Project", ["Name"] = "Residential", ["Slug"] = "residential", ["SortOrder"] = "0", ["__RequestVerificationToken"] = Token(html) };
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/categories/edit",new FormUrlEncodedContent(categoryForm))).StatusCode);
        using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        Assert.True(await db.Categories.AnyAsync(x => x.Translations.Any(t => t.Name == "Residential")));
        Assert.Equal(HttpStatusCode.OK,(await client.PostAsync("/admin/categories/edit",new FormUrlEncodedContent(categoryForm))).StatusCode);
        html = await client.GetStringAsync("/admin/settings");
        var settings = new Dictionary<string,string> { ["Brand"] = "Updated studio", ["HomeTitle"] = "New home title", ["HomeDescription"] = "New description", ["Phone"] = "", ["Email"] = "", ["Address"] = "", ["InstagramUrl"] = "", ["__RequestVerificationToken"] = Token(html) };
        var result = await client.PostAsync("/admin/settings",new FormUrlEncodedContent(settings)); Assert.Equal(HttpStatusCode.Redirect,result.StatusCode);
        db.ChangeTracker.Clear(); Assert.Equal("Updated studio",(await db.Settings.SingleAsync()).Brand);
    }
    [Fact] public async Task JsonLdIsValidAndArticleAuthorIsNotInvented()
    {
        var html = await client.GetStringAsync("/en/journal/studio-news");
        var json = Regex.Match(html,"<script type=\"application/ld[^\"]*\">([\\s\\S]*?)</script>").Groups[1].Value;
        using var document = System.Text.Json.JsonDocument.Parse(json);
        var article = document.RootElement.GetProperty("@graph").EnumerateArray().First(x => x.GetProperty("@type").GetString() == "Article");
        Assert.Equal("Organization",article.GetProperty("author").GetProperty("@type").GetString());
        Assert.Contains("+00:00",article.GetProperty("datePublished").GetString());
    }
    [Fact] public void ProductionQueriesTranslateForSqlServer()
    {
        using var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>().UseSqlServer("Server=localhost;Database=TranslateOnly;Trusted_Connection=True;TrustServerCertificate=True").Options);
        var site = new SiteService(db);
        var sql = site.Published("en",ContentKind.Project).Where(x => x.ContentItem.Featured).OrderBy(x => x.ContentItem.SortOrder).Take(12).ToQueryString();
        Assert.Contains("SELECT",sql); Assert.Contains("Published",sql);
        var migrationSql = db.GetService<Microsoft.EntityFrameworkCore.Migrations.IMigrator>().GenerateScript(options: Microsoft.EntityFrameworkCore.Migrations.MigrationsSqlGenerationOptions.Idempotent);
        Assert.Contains("CREATE TABLE [AspNetUsers]",migrationSql); Assert.Contains("CREATE TABLE [Contents]",migrationSql);
    }
    [Fact] public async Task RenderedMarkupHasOneMainHeadingAndNoDuplicateIds()
    {
        await Login();
        var export = Environment.GetEnvironmentVariable("ASEMANE_RENDER_DIR");
        foreach (var pair in new[] { ("/admin","dashboard"),("/admin/content","content"),("/admin/content/edit","edit"),("/en","home"),("/en/projects/garden-house","project") })
        {
            var response = await client.GetAsync(pair.Item1); var html = await response.Content.ReadAsStringAsync(); Assert.True(response.IsSuccessStatusCode,html);
            Assert.Single(Regex.Matches(html,"<h1[ >]",RegexOptions.IgnoreCase).Cast<Match>());
            var ids = Regex.Matches(html,"\\bid=\"([^\"]+)\"").Select(m => m.Groups[1].Value).ToList(); Assert.Equal(ids.Count,ids.Distinct().Count());
            if (export is not null) { Directory.CreateDirectory(export); await File.WriteAllTextAsync(Path.Combine(export,pair.Item2+".html"),html); }
        }
    }

    [Fact] public async Task PublicSectionsHaveIndependentControllersAndViews()
    {
        using var scope = factory.Services.CreateScope();
        var actions = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Mvc.Infrastructure.IActionDescriptorCollectionProvider>().ActionDescriptors.Items.OfType<Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor>().ToList();
        var views = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Mvc.ViewEngines.ICompositeViewEngine>();
        foreach (var expected in new[] { ("Home","Index","/{culture:siteCulture}"),("About","Index","/{culture:siteCulture}/about"),("Contact","Index","/{culture:siteCulture}/contact"),("Project","Index","/{culture:siteCulture}/projects"),("Project","Details","/{culture:siteCulture}/projects/{slug}"),("Blog","Index","/{culture:siteCulture}/journal"),("Blog","Details","/{culture:siteCulture}/journal/{slug}") })
        {
            Assert.Contains(actions,a => a.ControllerName == expected.Item1 && a.ActionName == expected.Item2 && a.AttributeRouteInfo?.Template == expected.Item3.TrimStart('/'));
            Assert.True(views.GetView(null,$"/Views/{expected.Item1}/{expected.Item2}.cshtml",true).Success);
        }
        Assert.DoesNotContain(actions,a => a.ControllerName == "Site");
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        foreach (var kind in new[] { ContentKind.Team, ContentKind.Page })
            db.Contents.Add(new ContentItem { Kind = kind, Translations = [new ContentTranslation { Kind = kind, Title = kind == ContentKind.Team ? "Test Architect" : "Studio story", Slug = kind == ContentKind.Team ? "architect" : "studio-story", Body = "Independent page.", Published = true, PublishedAt = DateTimeOffset.UtcNow.AddDays(-1) }] });
        await db.SaveChangesAsync();
        foreach (var path in new[] { "/en", "/en/about", "/en/contact", "/en/projects", "/en/projects/garden-house", "/en/journal", "/en/journal/studio-news", "/en/team/architect", "/en/pages/studio-story" })
        {
            var response = await client.GetAsync(path);
            Assert.True(response.IsSuccessStatusCode,path+" "+await response.Content.ReadAsStringAsync());
        }
        var about = await client.GetStringAsync("/en/about");
        Assert.Contains("about-page",about); Assert.Contains("Test Architect",about);
        var contact = await client.GetStringAsync("/en/contact"); Assert.Contains("contact-page",contact); Assert.DoesNotContain("Test Architect",contact);
        Assert.DoesNotContain("contact-page",await client.GetStringAsync("/en/pages/studio-story"));
        var oldAbout = await client.GetAsync("/en/pages/about"); Assert.Equal(HttpStatusCode.MovedPermanently,oldAbout.StatusCode); Assert.Equal("/en/about",oldAbout.Headers.Location!.ToString());
    }
    [Theory] [InlineData(" Garden House! ","garden-house")] [InlineData("---A---B---","a-b")] [InlineData("خانه باغ","خانه-باغ")]
    public void SlugsAreStable(string input,string expected) => Assert.Equal(expected,Slugs.Normalize(input));
    [Fact] public void ImageSignatureDoesNotTrustExtension() => Assert.Null(FileStorage.Detect("<script>alert(1)</script>"u8));

    [Fact] public async Task OriginalTemplateAssetsAndDynamicSlotsArePreserved()
    {
        using var scope = factory.Services.CreateScope();
        var web = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Hosting.IWebHostEnvironment>();
        var manifestPath = Path.GetFullPath(Path.Combine(web.ContentRootPath,"../../docs/template-assets.sha256.json"));
        var hashes = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string,string>>(await File.ReadAllTextAsync(manifestPath))!;
        Assert.NotEmpty(hashes);
        foreach (var entry in hashes)
        {
            var file = Path.Combine(web.ContentRootPath,"wwwroot/template",entry.Key);
            Assert.Equal(entry.Value,Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(await File.ReadAllBytesAsync(file))).ToLowerInvariant());
        }
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var project = await db.Contents.Include(x => x.Translations).SingleAsync(x => x.Translations.Any(t => t.Slug == "garden-house"));
        project.Translations.Single().ProjectStatus = "Completed";
        project.Translations.Single().Location = "Published location";
        foreach (var role in new[] {ImageRole.HomeFirst,ImageRole.ProjectCard,ImageRole.ProjectBanner}) project.Images.Add(new MediaAsset { Role=role, StoredName = "test.png", OriginalName = "test.png", ContentType = "image/png", Translations = [new MediaTranslation { Alt = "Published cover" }] });
        db.Contents.Add(new ContentItem { Kind = ContentKind.Team, Translations = [new ContentTranslation { Kind = ContentKind.Team, Slug = "architect", Title = "Template Architect", Summary = "Team biography", Published = true, PublishedAt = DateTimeOffset.UtcNow.AddDays(-1) }] });
        var settings = await db.Settings.SingleAsync(); settings.Phone = "07111111111;09111111111"; settings.Email = "studio@example.test";
        await db.SaveChangesAsync();
        Directory.CreateDirectory(Path.Combine(factory.Root,"uploads"));
        await File.WriteAllBytesAsync(Path.Combine(factory.Root,"uploads/test.png"),Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII="));
        var export = Environment.GetEnvironmentVariable("ASEMANE_RENDER_DIR");
        foreach (var pair in new[] { ("/en","template-home"),("/en/about","template-about"),("/en/contact","template-contact"),("/en/projects","template-grid"),("/en/projects/garden-house","template-project"),("/en/journal","template-blog"),("/en/journal/studio-news","template-article") })
        {
            var html = await client.GetStringAsync(pair.Item1);
            Assert.Contains("prague-header simple sticky-menu sticky-mobile-menu dark",html);
            Assert.Contains("/template/css/custome-03-03.css",html);
            Assert.DoesNotContain("/css/site.css",html);
            Assert.DoesNotContain("/js/site.js",html);
            Assert.DoesNotContain("Seascape",html);
            Assert.Single(Regex.Matches(html,"<h1[ >]",RegexOptions.IgnoreCase).Cast<Match>());
            foreach (Match asset in Regex.Matches(html,"(?:src|href)=\"(/template/[^\"]+)\""))
                Assert.Equal(HttpStatusCode.OK,(await client.GetAsync(asset.Groups[1].Value)).StatusCode);
            if (export is not null) { Directory.CreateDirectory(export); await File.WriteAllTextAsync(Path.Combine(export,pair.Item2+".html"),html); }
        }
        var home = await client.GetStringAsync("/en"); Assert.Contains("Published cover",home); Assert.Contains("swiper-slide",home);
        var detail = await client.GetStringAsync("/en/projects/garden-house"); Assert.Contains("Published location",detail); Assert.Contains("id=\"slides\"",detail); Assert.Contains("Published cover",detail);
        var about = await client.GetStringAsync("/en/about"); Assert.Contains("Template Architect",about); Assert.Contains("counter-num\">1</h6>",about);
        var contact = await client.GetStringAsync("/en/contact"); Assert.Contains("Shiraz",contact); Assert.Contains("tel:09111111111",contact); Assert.Contains("studio@example.test",contact);
    }
}
