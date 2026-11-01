namespace Asemane.Web.Services;
public static class Languages
{
    // در فاز دوم ابتدا ترجمه‌ها و منابع رابط کاربری فارسی تکمیل و سپس fa فعال شود.
    public static readonly string[] Enabled = ["en"];
    public static bool IsEnabled(string culture) => Enabled.Contains(culture, StringComparer.Ordinal);
}
