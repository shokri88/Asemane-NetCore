using System.Text.Json;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace Asemane.Tests;
public class SamplePackageTests
{
    [Fact] public async Task CurrentSampleManifestFitsTheRealModelAndEveryExplicitSlot()
    {
        using var factory=new CmsFactory();await factory.SeedAsync();using var scope=factory.Services.CreateScope();var db=scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.EnsureDeletedAsync();await db.Database.EnsureCreatedAsync();
        var root=Path.GetFullPath(Path.Combine(scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>().ContentRootPath,"../../docs/samples/v2"));
        using var document=JsonDocument.Parse(await File.ReadAllTextAsync(Path.Combine(root,"manifest.json")));var manifest=document.RootElement;
        var categories=new Dictionary<string,Category>();
        foreach(var row in manifest.GetProperty("categories").EnumerateArray()) {
            var category=new Category{Kind=(ContentKind)row.GetProperty("kind").GetInt32(),Translations=[new CategoryTranslation{Kind=(ContentKind)row.GetProperty("kind").GetInt32(),Culture="en",Slug=row.GetProperty("slug").GetString()!,Name=row.GetProperty("name").GetString()!}]};categories.Add(category.Translations[0].Slug,category);db.Categories.Add(category);
        }
        db.Settings.Add(new SiteSettings{Brand="Demo studio",Translations=[new SiteTranslation{HomeTitle="Demo home"}]});
        var filenames=new HashSet<string>();
        foreach(var row in manifest.GetProperty("contents").EnumerateArray()) {
            var kind=(ContentKind)row.GetProperty("kind").GetInt32();var category=row.GetProperty("category");
            var item=new ContentItem{Kind=kind,Key=row.GetProperty("key").GetString()!,Category=category.ValueKind==JsonValueKind.Null?null:categories[category.GetString()!],Featured=row.GetProperty("featured").GetBoolean(),Translations=[new ContentTranslation{Kind=kind,Slug=row.GetProperty("slug").GetString()!,Title=row.GetProperty("title").GetString()!,Summary=row.GetProperty("summary").GetString()!,Body=row.GetProperty("body").GetString()!,BodyIsHtml=true,Published=true,NoIndex=true,PublishedAt=DateTimeOffset.UtcNow.AddDays(-1)}]};
            foreach(var image in row.GetProperty("images").EnumerateArray()) {
                var role=(ImageRole)image.GetProperty("role").GetInt32();Assert.True(MediaRoles.IsAllowed(kind,role));Assert.NotEqual(0,(int)role);Assert.True(filenames.Add(image.GetProperty("name").GetString()!));
                item.Images.Add(new MediaAsset{Role=role,StoredName=image.GetProperty("name").GetString()!,ContentType="image/jpeg",Bytes=image.GetProperty("bytes").GetInt64(),SortOrder=image.GetProperty("order").GetInt32(),Translations=[new MediaTranslation{Alt=image.GetProperty("alt").GetString()!}]});
            }
            var roles=item.Images.Select(x=>x.Role).ToList();
            if(kind==ContentKind.Project){Assert.Equal(6,roles.Count);Assert.Equal(2,roles.Count(x=>x==ImageRole.ProjectGallery));Assert.All(new[]{ImageRole.HomeFirst,ImageRole.HomeSecond,ImageRole.ProjectCard,ImageRole.ProjectBanner},role=>Assert.Single(roles,x=>x==role));}
            if(kind==ContentKind.Article)Assert.Equal(new[]{ImageRole.ArticleSquare,ImageRole.ArticleBanner},roles);
            if(kind==ContentKind.Team)Assert.Equal(new[]{ImageRole.TeamSquare,ImageRole.TeamLandscape},roles);
            db.Contents.Add(item);
        }
        await db.SaveChangesAsync();Assert.Equal(20,await db.Contents.CountAsync());Assert.Equal(67,await db.Media.CountAsync());Assert.False(await db.Media.AnyAsync(x=>(int)x.Role==0));
        using var client=factory.CreateClient();
        foreach(var path in new[]{"/en","/en/about","/en/contact","/en/projects","/en/projects/demo-project-1","/en/journal","/en/journal/demo-article-1","/en/team/demo-member-1","/en/pages/demo-studio-story"})Assert.True((await client.GetAsync(path)).IsSuccessStatusCode,path);
        var seed=await File.ReadAllTextAsync(Path.Combine(root,"02-sample-data.sql"));Assert.DoesNotContain("IsCover",seed);
        var reset=await File.ReadAllTextAsync(Path.Combine(root,"00-reset-data.sql"));Assert.DoesNotContain("DELETE FROM dbo.__EFMigrationsHistory",reset);Assert.Contains("DELETE FROM dbo.AspNetUsers",reset);Assert.DoesNotContain("DROP DATABASE",reset);
    }
}
