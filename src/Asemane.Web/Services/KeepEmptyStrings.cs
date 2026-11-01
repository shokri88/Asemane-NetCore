using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
using System.Reflection;
namespace Asemane.Web.Services;
// فیلدهای اختیاری فرم، رشته خالی را به null تبدیل نکنند؛ با ستون‌های NOT NULL هماهنگ است.
public class KeepEmptyStrings : IDisplayMetadataProvider
{
    public void CreateDisplayMetadata(DisplayMetadataProviderContext context)
    {
        var nullable = context.Key.PropertyInfo is { } property && new NullabilityInfoContext().Create(property).ReadState == NullabilityState.Nullable;
        if (context.Key.ModelType == typeof(string) && !nullable) context.DisplayMetadata.ConvertEmptyStringToNull = false;
    }
}
