using System.Text.Json;
using Asemane.Tests;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

// فقط میزبان fixture تست است؛ هیچ اتصال/حساب/داده‌ای در برنامه واقعی تغییر نمی‌کند.
var repo = Path.GetFullPath(args.ElementAtOrDefault(0) ?? Directory.GetCurrentDirectory());
var template = Path.GetFullPath(args.ElementAtOrDefault(1) ?? Path.Combine(repo,"..","Asemane-UI"));
var output = Path.GetFullPath(args.ElementAtOrDefault(2) ?? Path.Combine(Path.GetTempPath(),"asemane-template-audit"));
var port = int.Parse(args.ElementAtOrDefault(3) ?? "7445");
Directory.CreateDirectory(output);
using var factory = new AuditFactory(Path.Combine(repo,"src/Asemane.Web"));
factory.UseKestrel(options => options.ListenLocalhost(port,listen => listen.UseHttps()));
await factory.SeedAsync();
using (var scope = factory.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var photos = Directory.GetFiles(Path.Combine(template,"img/carousel-showcase"),"*.jpg").OrderBy(x => x).ToArray();
    var square = Path.Combine(template,"img/work-grid/400x400.webp");
    var avatar = Path.Combine(template,"img/work-grid/51f1b143659493.57f77d5c9619a-768x512.jpg");
    var category = new Category { Kind=ContentKind.Project, Translations=[new CategoryTranslation {Kind=ContentKind.Project,Name="Residential",Slug="residential"}] };
    var body = "First paragraph for template comparison.\n\nSecond paragraph with architectural details.";
    void Image(ContentItem item, string source, ImageRole role, int order = 0)
    {
        var name = Guid.NewGuid().ToString("N")+Path.GetExtension(source);
        var directory = Path.Combine(factory.Root,"uploads"); Directory.CreateDirectory(directory);
        File.Copy(source,Path.Combine(directory,name));
        item.Images.Add(new MediaAsset { Role=role,StoredName=name,ContentType=name.EndsWith(".webp") ? "image/webp" : "image/jpeg",Bytes=new FileInfo(source).Length,SortOrder=order,Translations=[new MediaTranslation {Alt="Audit image "+role}] });
    }
    ContentItem New(ContentKind kind,string slug,string title,int order) => new() {Kind=kind,SortOrder=order,Translations=[new ContentTranslation {Kind=kind,Slug=slug,Title=title,Body=body,Summary="Architectural studio description for the original template comparison.",MetaDescription="Audit description",Published=true,PublishedAt=DateTimeOffset.UtcNow.AddDays(-1)}]};
    var first = await db.Contents.Include(x=>x.Translations).SingleAsync(x=>x.Translations.Any(t=>t.Slug=="garden-house"));
    for(var i=0;i<12;i++)
    {
        var project = i==0 ? first : New(ContentKind.Project,"audit-project-"+(i+1),"Garden House "+(i+1),i);
        if(i>0) db.Contents.Add(project);
        project.Featured=i<9;project.Category=category;project.Area=200+i*10;project.Year=2023;project.Translations[0].Location="Shiraz";project.Translations[0].ProjectStatus="Completed";
        Image(project,photos[i%photos.Length],ImageRole.HomeFirst);Image(project,photos[(i+1)%photos.Length],ImageRole.HomeSecond);
        Image(project,square,ImageRole.ProjectCard);Image(project,photos[1],ImageRole.ProjectBanner);
        if(i==0) for(var j=0;j<10;j++) Image(project,photos[j%photos.Length],ImageRole.ProjectGallery,j);
    }
    var article=await db.Contents.Include(x=>x.Translations).SingleAsync(x=>x.Translations.Any(t=>t.Slug=="studio-news"));
    article.SortOrder=0;article.Translations[0].Summary="Studio news and architecture projects. A sample summary for the original blog list.";Image(article,avatar,ImageRole.ArticleSquare);Image(article,photos[1],ImageRole.ArticleBanner);
    for(var i=1;i<3;i++) {var item=New(ContentKind.Article,"audit-article-"+i,"Studio Journal "+i,i);Image(item,avatar,ImageRole.ArticleSquare);Image(item,photos[1],ImageRole.ArticleBanner);db.Contents.Add(item);}
    for(var i=0;i<6;i++) {var member=New(ContentKind.Team,"architect-"+(i+1),"Architect "+(i+1),i);Image(member,avatar,ImageRole.TeamSquare);Image(member,photos[1],ImageRole.TeamLandscape);db.Contents.Add(member);}
    var page=New(ContentKind.Page,"studio-story","Studio story",0);Image(page,photos[1],ImageRole.PageBanner);db.Contents.Add(page);
    var settings=await db.Settings.Include(x=>x.Translations).SingleAsync();settings.AboutTotalValue=40;settings.AboutDesignValue=10;settings.AboutConstructionValue=10;settings.AboutCompletedValue=20;
    settings.Phone="07136301671;09364682225;09365172081";settings.PostalCode="71868-46578";settings.Email="studio@example.test";settings.Translations[0].Address="Studio address, Shiraz, Iran";
    await db.SaveChangesAsync();
    File.WriteAllText(Path.Combine(output,"host.json"),JsonSerializer.Serialize(new {url="https://localhost:"+port,projectId=first.Id,templateRoot=template,repositoryRoot=repo}));
}
Console.WriteLine("TEMPLATE_AUDIT_READY https://localhost:"+port);
var lifetime=factory.Services.GetRequiredService<IHostApplicationLifetime>();
try {await Task.Delay(Timeout.Infinite,lifetime.ApplicationStopping);} catch(OperationCanceledException) { }
sealed class AuditFactory(string contentRoot) : CmsFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder) {base.ConfigureWebHost(builder);builder.UseContentRoot(contentRoot);}
}
