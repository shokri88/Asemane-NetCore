# پایگاه داده و مدل محتوا

Provider برنامه اصلی `Microsoft.EntityFrameworkCore.SqlServer` است. دیتابیس SQL Server با EF Migration ساخته می‌شود. فایل [initial.sql](database/initial.sql) خروجی idempotent EF برای بازبینی DBA است؛ این فایل را از روی Migration بازتولید کنید، نه دستی.

## جدول‌ها

| موجودیت | داده و رابطه |
|---|---|
| ContentItem | نوع، کلید صفحه سیستمی، دسته، مساحت، سال، Featured، ترتیب، حذف نرم، تاریخ UTC و Version |
| ContentTranslation | ContentItemId + Culture؛ عنوان، اسلاگ، خلاصه، متن، سمت/موقعیت/وضعیت پروژه، نویسنده، سئو و انتشار |
| Category | نوع پروژه/مقاله و ترتیب |
| CategoryTranslation | عنوان و اسلاگ هر زبان؛ Kind برای ایندکس یکتایی زبان/نوع/اسلاگ |
| MediaAsset | ارتباط اختیاری با محتوا، نام فایل داخلی، نام اصلی، MIME، حجم، Cover و ترتیب |
| MediaTranslation | Alt و Caption هر زبان برای یک تصویر |
| SiteSettings | یک ردیف تنظیمات: برند، تماس، شبکه اجتماعی، مختصات، لوگو و آمار |
| SiteTranslation | عنوان و توضیحات خانه و آدرس هر زبان |
| SlugRedirect | نوع/زبان/اسلاگ قبلی ← ContentItemId؛ مقصد همیشه از ترجمه فعلی محاسبه می‌شود |
| AspNetUsers و جداول Identity | کاربران، نقش‌ها، claim، token و login استاندارد Identity |

## یکتایی و رابطه

- ContentTranslation: `(ContentItemId, Culture)` و `(Kind, Culture, Slug)` یکتا.
- CategoryTranslation: `(CategoryId, Culture)` و `(Kind, Culture, Slug)` یکتا.
- MediaTranslation: `(MediaAssetId, Culture)` یکتا.
- SiteTranslation: `(SiteSettingsId, Culture)` یکتا.
- SlugRedirect: `(Kind, Culture, OldSlug)` یکتا.
- حذف دسته‌ای که محتوا به آن اشاره دارد ممنوع است؛ رابطه Restrict از حذف تصادفی جلوگیری می‌کند.
- فایل‌های رسانه در حذف محتوا cascade نمی‌شوند؛ حذف محتوا نرم است.
- Kind در ترجمه محتوا/دسته هنگام ثبت توسط Controller تعیین می‌شود، نه با ورودی آزاد کاربر.
- Area از نوع decimal(12,2)، مختصات decimal(9,6)، زمان‌ها DateTimeOffset هستند.

## انتشار

هر ترجمه Published و PublishedAt مستقل دارد. اولین انتشار زمان UTC را ثبت می‌کند؛ ویرایش بعدی زمان اولین انتشار را بازنویسی نمی‌کند. داده عمومی فقط وقتی برمی‌گردد که محتوا حذف نشده، زبان فعال، Published=true و PublishedAt در آینده نباشد. زمان‌بندی انتشار رابط مدیریتی ندارد؛ شرط زمان برای توسعه بعدی آماده است.

## حذف و بازیابی

محتوا `IsDeleted=true` می‌شود و فایل‌ها و ترجمه‌ها باقی می‌مانند. صفحات سیستمی about/contact حذف نمی‌شوند؛ می‌توان انتشارشان را خاموش کرد. در این نسخه صفحه سطل زباله/بازیابی وجود ندارد؛ بازیابی توسط توسعه‌دهنده با تغییر IsDeleted و Version انجام می‌شود. رسانه از صفحه تصاویر به‌صورت واقعی حذف می‌شود. تا وقتی حذف نرم باقی است، اسلاگ همان محتوا رزرو است.

## Migration

```powershell
dotnet tool restore
dotnet ef database update --project src/Asemane.Web
dotnet ef migrations has-pending-model-changes --project src/Asemane.Web
dotnet ef migrations script --idempotent --project src/Asemane.Web --output docs/database/initial.sql
```

Bootstrap نقش‌ها/مدیر/صفحات پایه را نیز ایجاد می‌کند؛ اجرای فقط SQL یا database update حساب مدیر نمی‌سازد. برای محیط production، migration با حساب DBA و bootstrap با تنظیمات مناسب اجرا شود. ساخت خودکار DB در شروع هر درخواست یا اجرای عادی برنامه وجود ندارد.

## داده آزمون

TestDbContext داخل پروژه تست از SQLite و تبدیل DateTimeOffset فقط برای تست استفاده می‌کند؛ این کلاس و seedهای آزمایشی وارد DbContext اصلی یا DB production نمی‌شوند. سازگاری SQL Server علاوه بر تست قابل‌حمل باید روی SQL Server واقعی بررسی شود.

## ارتقای ۱۰ نوامبر ۲۰۲۶

Migration جدید `20261110104023_ProjectMediaRolesRichTextAndContact` ستون‌های `Media.Role` (پیش‌فرض عمومی=0)، `ContentTranslations.BodyIsHtml` (پیش‌فرض false)، `Settings.PostalCode` و `Settings.MapEmbedUrl` (خالی) را اضافه و Phone را از ۵۰ به ۲۰۰ نویسه گسترش می‌دهد. index یکتای فیلترشده فقط برای نقش‌های ۱ تا ۴ پروژه و index غیر یکتای قبلی برای lookup همه تصاویر حفظ می‌شود. داده‌های قدیمی حذف یا بازنویسی نمی‌شوند.

SQL idempotent ارتقا از Migration اولیه: `docs/database/20261110-project-media-richtext-contact.sql`. فایل `initial.sql` تاریخی فقط schema اولیه را دارد؛ دیتابیس جدید نیز باید هر دو Migration را اعمال کند. اجرای عادی وب‌سایت Migration را اعمال نمی‌کند. پیش از اجرای نسخه جدید، `dotnet ef database update --project src/Asemane.Web` را طبق SETUP اجرا کنید. Rollback بعد از ثبت محتوای جدید نیازمند backup است، چون Down ستون‌های جدید را حذف می‌کند.

## ارتقای About

Migration `AboutStatisticsAndTeamImages` چهار ستون عنوان `AboutTotalTitle`، `AboutDesignTitle`، `AboutConstructionTitle` و `AboutCompletedTitle` را در SiteTranslation با defaultهای اصلی قالب و چهار ستون nullable عدد متناظر در Settings اضافه می‌کند. null مقدار خودکار قبلی را حفظ می‌کند و صفر override دستی است. index یکتای جایگاه‌های رسانه به نقش‌های ۱،۲،۳،۴،۶،۷،۸ محدود است؛ نقش عمومی و گالری همچنان چندتایی‌اند. داده موجود حذف یا بازنویسی نمی‌شود.

SQL idempotent این ارتقا پس از Migration قبلی: `docs/database/20261110-about-statistics-team-images.sql`. قبل از اجرای برنامه `dotnet ef database update --project src/Asemane.Web` را اجرا کنید. Down مقادیر جدید را حذف می‌کند؛ rollback پس از ورود داده جدید به backup نیاز دارد.
