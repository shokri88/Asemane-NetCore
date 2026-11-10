using System.Net;
using System.Text.RegularExpressions;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace Asemane.Tests;
public class AboutManagementTests : IAsyncLifetime
{
    private readonly CmsFactory factory = new();
    private HttpClient client = null!;
    public async Task InitializeAsync() { await factory.SeedAsync(); client = factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false }); }
    public Task DisposeAsync() { client.Dispose(); factory.Dispose(); return Task.CompletedTask; }
    private static string Token(string html) => Regex.Match(html,"name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"").Groups[1].Value;
    private async Task Login()
    {
        var html = await client.GetStringAsync("/admin/account/login");
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string> { ["Email"] = CmsFactory.AdminEmail, ["Password"] = CmsFactory.Password, ["__RequestVerificationToken"] = Token(html) }))).StatusCode);
    }
    [Fact] public async Task FourAboutStatisticsCanBeRenamedAndOverriddenIncludingZero()
    {
        await Login(); var html = await client.GetStringAsync("/admin/settings");
        var form = new Dictionary<string,string> { ["Brand"] = "Studio", ["HomeTitle"] = "Home", ["AboutTotalTitle"] = "Awards <em>plain</em>", ["AboutTotalValue"] = "0", ["AboutDesignTitle"] = "Happy clients", ["AboutDesignValue"] = "42", ["AboutConstructionTitle"] = "Countries", ["AboutConstructionValue"] = "1000000000", ["AboutCompletedTitle"] = "Years", ["AboutCompletedValue"] = "12", ["__RequestVerificationToken"] = Token(html) };
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/settings",new FormUrlEncodedContent(form))).StatusCode);
        html = await client.GetStringAsync("/en/about"); Assert.Contains("Awards &lt;em&gt;plain&lt;/em&gt;",html); Assert.Contains("Happy clients",html);Assert.Contains("Countries",html);Assert.Contains("Years",html);
        Assert.Equal(new[] { "0", "42", "1000000000", "12" },Regex.Matches(html,"class=\"counter-num\">(\\d+)</h6>").Select(x => x.Groups[1].Value));
        Assert.Contains("/js/about-counters.js",html);Assert.DoesNotContain("addtListener",html);
        var settings = await client.GetStringAsync("/admin/settings"); Assert.Contains("value=\"42\"",settings); Assert.Contains("Happy clients",settings);
        form["AboutTotalValue"] = "";
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/settings",new FormUrlEncodedContent(form))).StatusCode);
        html = await client.GetStringAsync("/en/about");Assert.Equal("1",Regex.Matches(html,"class=\"counter-num\">(\\d+)</h6>")[0].Groups[1].Value);
        form["AboutDesignValue"] = "-1";
        Assert.Equal(HttpStatusCode.OK,(await client.PostAsync("/admin/settings",new FormUrlEncodedContent(form))).StatusCode);
        Assert.Contains("counter-num\">42</h6>",await client.GetStringAsync("/en/about"));
    }
    [Fact] public async Task TeamHasTwoIndependentSlotsWithServerAndDatabaseUniqueness()
    {
        await Login(); using var scope = factory.Services.CreateScope();var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var team = new ContentItem { Kind = ContentKind.Team, Translations = [new ContentTranslation { Kind = ContentKind.Team, Title = "Architect", Slug = "architect", Body = "Biography", Published = true, PublishedAt = DateTimeOffset.UtcNow.AddDays(-1) }] };
        db.Contents.Add(team);await db.SaveChangesAsync();
        async Task<HttpResponseMessage> Upload(ImageRole role) {
            var html=await client.GetStringAsync("/admin/media?contentId="+team.Id);
            using var form=new MultipartFormDataContent();form.Add(new StringContent(Token(html)),"__RequestVerificationToken");form.Add(new StringContent(team.Id.ToString()),"contentId");form.Add(new StringContent(role.ToString()),"role");form.Add(new StringContent(role.ToString()),"alt");
            form.Add(new ByteArrayContent(Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII=")),"file","image.png");
            return await client.PostAsync("/admin/media/upload",form);
        }
        foreach(var role in new[]{ImageRole.TeamSquare,ImageRole.TeamLandscape})Assert.Equal(HttpStatusCode.Redirect,(await Upload(role)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.TeamSquare)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,(await Upload(ImageRole.HomeFirst)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,(await Upload((ImageRole)8)).StatusCode);
        var media=await db.Media.Where(x=>x.ContentItemId==team.Id).ToListAsync();Assert.Equal(2,media.Count);Assert.Equal(2,Directory.GetFiles(Path.Combine(factory.Root,"uploads")).Length);
        string Src(ImageRole role)=>"src=\"/media/"+media.Single(x=>x.Role==role).Id+"\"";
        var about=await client.GetStringAsync("/en/about");Assert.Contains(Src(ImageRole.TeamSquare),about);Assert.DoesNotContain(Src(ImageRole.TeamLandscape),about);
        var detail=await client.GetStringAsync("/en/team/architect");Assert.Contains(Src(ImageRole.TeamLandscape),detail);Assert.DoesNotContain(Src(ImageRole.TeamSquare),detail);
        Assert.Single(Regex.Matches(detail,"class=\"project-details-slider-3d\""));
        db.Media.Add(new MediaAsset{ContentItemId=team.Id,Role=ImageRole.TeamSquare,StoredName="duplicate.png"});
        await Assert.ThrowsAsync<DbUpdateException>(()=>db.SaveChangesAsync());
    }
    [Fact] public async Task RetiredThirdSlotIsPreservedAsGeneralMedia()
    {
        using var scope=factory.Services.CreateScope();var db=scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var team=new ContentItem {Kind=ContentKind.Team,Images=[new MediaAsset {Role=(ImageRole)8,StoredName="retired.png"}]};
        db.Contents.Add(team);await db.SaveChangesAsync();
        var root=Path.Combine(factory.Root,"uploads");Directory.CreateDirectory(root);var path=Path.Combine(root,"retired.png");await File.WriteAllTextAsync(path,"preserve file");
        var migration=new Asemane.Web.Data.Migrations.LimitTeamToTwoImages();
        foreach(var operation in migration.UpOperations.OfType<Microsoft.EntityFrameworkCore.Migrations.Operations.SqlOperation>()) await db.Database.ExecuteSqlRawAsync(operation.Sql);
        db.ChangeTracker.Clear();var media=await db.Media.SingleAsync();Assert.Equal(ImageRole.General,media.Role);Assert.Equal("retired.png",media.StoredName);Assert.Equal("preserve file",await File.ReadAllTextAsync(path));
    }
    [Fact] public async Task LegacyTeamCoverStillAppearsInAboutAndMemberPage()
    {
        using var scope=factory.Services.CreateScope();var db=scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var team=new ContentItem{Kind=ContentKind.Team,Translations=[new ContentTranslation{Kind=ContentKind.Team,Slug="legacy-member",Title="Legacy member",Body="Text",Published=true,PublishedAt=DateTimeOffset.UtcNow.AddDays(-1)}],Images=[new MediaAsset{StoredName="legacy.jpg",IsCover=true}]};db.Contents.Add(team);await db.SaveChangesAsync();
        var src="src=\"/media/"+team.Images.Single().Id+"\"";
        Assert.Contains(src,await client.GetStringAsync("/en/about"));Assert.Contains(src,await client.GetStringAsync("/en/team/legacy-member"));
    }
}
