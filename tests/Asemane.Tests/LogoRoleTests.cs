using System.Net;
using System.Text.RegularExpressions;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
namespace Asemane.Tests;
public class LogoRoleTests
{
    [Fact] public async Task SettingsLogoUsesExplicitRoleWithoutContentParent()
    {
        using var factory=new CmsFactory();await factory.SeedAsync();using var client=factory.CreateClient(new WebApplicationFactoryClientOptions{BaseAddress=new Uri("https://localhost"),AllowAutoRedirect=false});
        string Token(string html)=>Regex.Match(html,"name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"").Groups[1].Value;
        var login=await client.GetStringAsync("/admin/account/login");await client.PostAsync("/admin/account/login",new FormUrlEncodedContent(new Dictionary<string,string>{["Email"]=CmsFactory.AdminEmail,["Password"]=CmsFactory.Password,["__RequestVerificationToken"]=Token(login)}));
        var settings=await client.GetStringAsync("/admin/settings");using var form=new MultipartFormDataContent();form.Add(new StringContent(Token(settings)),"__RequestVerificationToken");form.Add(new StringContent("Studio"),"Brand");form.Add(new StringContent("Home"),"HomeTitle");form.Add(new ByteArrayContent(Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a66kAAAAASUVORK5CYII=")),"Logo","logo.png");
        Assert.Equal(HttpStatusCode.Redirect,(await client.PostAsync("/admin/settings",form)).StatusCode);
        using var scope=factory.Services.CreateScope();var db=scope.ServiceProvider.GetRequiredService<AppDbContext>();var media=await db.Media.SingleAsync();Assert.Equal(ImageRole.SiteLogo,media.Role);Assert.Null(media.ContentItemId);Assert.Equal(media.Id,(await db.Settings.SingleAsync()).LogoId);Assert.Null(db.Model.FindEntityType(typeof(MediaAsset))!.FindProperty("IsCover"));
        Assert.Equal(HttpStatusCode.OK,(await client.GetAsync("/media/"+media.Id)).StatusCode);
    }
}
