using System.Globalization;
using Asemane.Web.Models;
namespace Asemane.Web.Helpers;
public static class Display
{
    public static string ImageType(ImageRole role) => role switch
    {
        ImageRole.HomeFirst => "خانه — تصویر اول (عمودی)",
        ImageRole.HomeSecond => "خانه — تصویر دوم (عمودی)",
        ImageRole.ProjectCard => "فهرست پروژه‌ها (مربعی)",
        ImageRole.ProjectBanner => "هدر جزئیات پروژه (افقی)",
        ImageRole.ProjectGallery => "گالری پایین پروژه (افقی)",
        _ => "تصویر عمومی / قدیمی"
    };
    public static string Persian(object? value) => string.Concat((Convert.ToString(value,CultureInfo.InvariantCulture) ?? "").Select(c => c >= '0' && c <= '9' ? (char)('۰' + c - '0') : c));
    public static string Date(DateTimeOffset value)
    {
        var date = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(value,"Asia/Tehran").DateTime;
        var p = new PersianCalendar();
        return Persian($"{p.GetYear(date):0000}/{p.GetMonth(date):00}/{p.GetDayOfMonth(date):00}");
    }
    public static string Kind(ContentKind kind) => kind switch { ContentKind.Project => "پروژه‌ها", ContentKind.Article => "مقالات", ContentKind.Page => "صفحات", ContentKind.Team => "اعضای تیم", _ => "محتوا" };
}
