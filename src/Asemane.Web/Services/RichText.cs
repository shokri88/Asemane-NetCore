using System.Text.Encodings.Web;
using AngleSharp.Html.Parser;
using Ganss.Xss;
using Microsoft.AspNetCore.Html;
using Asemane.Web.Models;
namespace Asemane.Web.Services;

public static class RichText
{
    public static string Sanitize(string html)
    {
        // حتی HTML ذخیره‌شده هنگام نمایش دوباره پاک‌سازی می‌شود؛ به ورودی ویرایشگر اعتماد نمی‌کنیم.
        var sanitizer = new HtmlSanitizer();
        sanitizer.AllowedTags.Clear();
        foreach (var tag in new[] { "p", "div", "span", "br", "h2", "h3", "h4", "blockquote", "pre", "code", "strong", "b", "em", "i", "u", "s", "strike", "sub", "sup", "ol", "ul", "li", "a", "table", "thead", "tbody", "tfoot", "tr", "th", "td", "hr" }) sanitizer.AllowedTags.Add(tag);
        sanitizer.AllowedAttributes.Clear();
        foreach (var attribute in new[] { "href", "title", "style", "colspan", "rowspan", "scope", "dir" }) sanitizer.AllowedAttributes.Add(attribute);
        sanitizer.AllowedSchemes.Clear();
        foreach (var scheme in new[] { "https", "http", "mailto", "tel" }) sanitizer.AllowedSchemes.Add(scheme);
        sanitizer.AllowedCssProperties.Clear();
        foreach (var property in new[] { "text-align", "color", "background-color", "font-weight", "font-style", "text-decoration" }) sanitizer.AllowedCssProperties.Add(property);
        return sanitizer.Sanitize(html ?? "");
    }

    public static bool HasText(string value, bool isHtml) => !string.IsNullOrWhiteSpace(isHtml
        ? new HtmlParser().ParseDocument(Sanitize(value)).Body?.TextContent.Replace('\u00a0',' ')
        : value);

    public static IHtmlContent Render(ContentTranslation text) => new HtmlString(EditorValue(text.Body,text.BodyIsHtml));

    public static string EditorValue(string body, bool isHtml)
    {
        if (isHtml) return Sanitize(body);
        // متن‌های نسخه قبلی HTML محسوب نمی‌شوند و بدون از دست رفتن متن به ویرایشگر منتقل می‌شوند.
        var blocks = new List<string>();
        string Encode(string value) => HtmlEncoder.Default.Encode(value);
        foreach (var raw in body.Replace("\r", "").Split("\n\n",StringSplitOptions.RemoveEmptyEntries))
        {
            var block = raw.Trim();
            if (block.StartsWith("### ")) blocks.Add("<h3>"+Encode(block[4..])+"</h3>");
            else if (block.StartsWith("## ")) blocks.Add("<h2>"+Encode(block[3..])+"</h2>");
            else if (block.Split('\n').All(line => line.StartsWith("- "))) blocks.Add("<ul>"+string.Concat(block.Split('\n').Select(line => "<li>"+Encode(line[2..])+"</li>"))+"</ul>");
            else blocks.Add("<p>"+Encode(block)+"</p>");
        }
        return string.Concat(blocks);
    }
}
