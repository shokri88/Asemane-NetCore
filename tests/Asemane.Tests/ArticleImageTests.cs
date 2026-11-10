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
public class ArticleImageTests
{
    [Fact] public async Task ArticleFormsSaveTwoIndependentUniqueImagesAndRenderCorrectSlots()
    {
        using var factory=new CmsFactory();await factory.SeedAsync();
        using var client=factory.CreateClient(new WebApplicationFactoryClientOptions{BaseAddress=new Uri("https://localhost"),AllowAutoRedirect=false});
        string Token(string html)=>Regex.Match(html,"name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"").Groups[1].Value;
        var login=await client.GetStringAsync("/admin/account/login");
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string>{["Email"]=CmsFactory.AdminEmail,["Password"]=CmsFactory.Password,["__RequestVerificationToken"]=Token(login)}))).StatusCode);
        using var scope=factory.Services.CreateScope();var db=scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var article=await db.Contents.SingleAsync(x=>x.Translations.Any(t=>t.Slug=="studio-news"));
        async Task<HttpResponseMessage> Upload(ImageRole role){
            var html=await client.GetStringAsync("/admin/media?contentId="+article.Id);
            using var form=new MultipartFormDataContent();form.Add(new StringContent(Token(html)),"__RequestVerificationToken");form.Add(new StringContent(article.Id.ToString()),"contentId");form.Add(new StringContent(role.ToString()),"role");form.Add(new StringContent(role.ToString()),"alt");
            form.Add(new ByteArrayContent(Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII=")),"file","image.png");
            return await client.PostAsync("/admin/media/upload",form);
        }
        foreach(var role in new[]{ImageRole.ArticleSquare,ImageRole.ArticleBanner}) Assert.Equal(HttpStatusCode.Redirect,(await Upload(role)).StatusCode);
        Assert.Equal(HttpStatusCode.Redirect,(await Upload(ImageRole.ArticleBanner)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,(await Upload(ImageRole.TeamSquare)).StatusCode);
        var media=await db.Media.Where(x=>x.ContentItemId==article.Id).ToListAsync();Assert.Equal(2,media.Count);Assert.Equal(2,Directory.GetFiles(Path.Combine(factory.Root,"uploads")).Length);
        var square=media.Single(x=>x.Role==ImageRole.ArticleSquare);var banner=media.Single(x=>x.Role==ImageRole.ArticleBanner);
        var list=await client.GetStringAsync("/en/journal");Assert.Contains("src=\"/media/"+square.Id+"\"",list);Assert.DoesNotContain("src=\"/media/"+banner.Id+"\"",list);
        var detail=await client.GetStringAsync("/en/journal/studio-news");Assert.Contains("src=\"/media/"+banner.Id+"\"",detail);Assert.DoesNotContain("src=\"/media/"+square.Id+"\"",detail);Assert.Contains("https://studio.test/media/"+banner.Id,detail);
        var edit=await client.GetStringAsync("/admin/media?contentId="+article.Id);
        await client.PostAsync("/admin/media/update",new FormUrlEncodedContent(new Dictionary<string,string>{["Id"]=square.Id.ToString(),["ContentId"]=article.Id.ToString(),["Alt"]="Square",["Role"]="ArticleBanner",["__RequestVerificationToken"]=Token(edit)}));
        db.ChangeTracker.Clear();Assert.Equal(ImageRole.ArticleSquare,(await db.Media.FindAsync(square.Id))!.Role);
        db.Media.Add(new MediaAsset{ContentItemId=article.Id,Role=ImageRole.ArticleBanner,StoredName="duplicate.png"});await Assert.ThrowsAsync<DbUpdateException>(()=>db.SaveChangesAsync());
    }
    [Fact] public void LegacyArticleImagesRemainAvailableUntilEachSlotIsAssigned()
    {
        var legacy=new MediaAsset{Id=1,Role=ImageRole.General,IsCover=true};var article=new ContentItem{Kind=ContentKind.Article,Images=[legacy]};
        Assert.Same(legacy,SiteService.ArticleImage(article,ImageRole.ArticleSquare));Assert.Same(legacy,SiteService.ArticleImage(article,ImageRole.ArticleBanner));
        var square=new MediaAsset{Id=2,Role=ImageRole.ArticleSquare};article.Images.Add(square);
        Assert.Same(square,SiteService.ArticleImage(article,ImageRole.ArticleSquare));Assert.Same(legacy,SiteService.ArticleImage(article,ImageRole.ArticleBanner));
        article.Images.Remove(legacy);Assert.Null(SiteService.ArticleImage(article,ImageRole.ArticleBanner));
    }
}
