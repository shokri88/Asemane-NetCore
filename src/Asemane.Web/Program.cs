using System.Globalization;
using Asemane.Web.Data;
using Asemane.Web.Models;
using Asemane.Web.Services;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(o =>
{
    o.User.RequireUniqueEmail = true;
    o.Password.RequiredLength = 12;
    o.Lockout.MaxFailedAccessAttempts = 5;
    o.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
}).AddEntityFrameworkStores<AppDbContext>().AddDefaultTokenProviders();
builder.Services.Configure<SecurityStampValidatorOptions>(o => o.ValidationInterval = TimeSpan.FromMinutes(1));
builder.Services.ConfigureApplicationCookie(o =>
{
    o.LoginPath = "/admin/account/login";
    o.AccessDeniedPath = "/admin/account/denied";
    o.Cookie.Name = "Asemane.Admin";
    o.Cookie.HttpOnly = true;
    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    o.Cookie.SameSite = SameSiteMode.Lax;
    o.ExpireTimeSpan = TimeSpan.FromHours(2);
    o.SlidingExpiration = true;
});
builder.Services.AddControllersWithViews(o => { o.Filters.Add(new AutoValidateAntiforgeryTokenAttribute()); o.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true; o.ModelMetadataDetailsProviders.Add(new KeepEmptyStrings()); });
builder.Services.Configure<Microsoft.AspNetCore.Http.Features.FormOptions>(o => o.MultipartBodyLengthLimit = 10 * 1024 * 1024);
builder.WebHost.ConfigureKestrel(o => o.Limits.MaxRequestBodySize = 10 * 1024 * 1024);
builder.Services.Configure<Microsoft.AspNetCore.Routing.RouteOptions>(o => o.ConstraintMap["siteCulture"] = typeof(SiteCultureConstraint));
builder.Services.AddScoped<FileStorage>();
builder.Services.AddScoped<SiteService>();
builder.Services.AddScoped<PublicContentService>();
builder.Services.AddScoped<SeoService>();
var keyPath = builder.Configuration["DataProtection:KeysPath"] ?? "App_Data/Keys";
var keyDirectory = new DirectoryInfo(Path.GetFullPath(Path.IsPathRooted(keyPath) ? keyPath : Path.Combine(builder.Environment.ContentRootPath,keyPath)));
keyDirectory.Create();
builder.Services.AddDataProtection().PersistKeysToFileSystem(keyDirectory).SetApplicationName("Asemane.Cms");
var app = builder.Build();
if (args.Contains("--bootstrap")) { await Bootstrapper.RunAsync(app.Services, app.Configuration); return; }
if (!app.Environment.IsDevelopment()) { app.UseExceptionHandler("/error"); app.UseHsts(); }
app.UseHttpsRedirection();
app.Use(async (context,next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["X-Frame-Options"] = "SAMEORIGIN";
    if (context.Request.Path.StartsWithSegments("/admin"))
    {
        context.Response.Headers["X-Robots-Tag"] = "noindex, nofollow";
        context.Response.Headers.CacheControl = "no-store";
        CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo("fa-IR");
        CultureInfo.CurrentUICulture = CultureInfo.GetCultureInfo("fa-IR");
    }
    await next();
});
app.UseStatusCodePagesWithReExecute("/status/{0}");
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllerRoute("areas", "{area:exists}/{controller=Dashboard}/{action=Index}/{id?}");
app.MapControllers();
app.Run();
public partial class Program { }
