# آسمانه — سایت معماری و مدیریت محتوا

وب‌سایت انگلیسی استودیوی معماری آسمانه با پنل مدیریت فارسی، بر پایه ASP.NET Core MVC، Razor Views، SQL Server، EF Core و Identity. زیرساخت ترجمه فارسی از ابتدا در مدل داده وجود دارد؛ زبان عمومی فارسی هنوز فعال نیست.

## شروع از اینجا

| موضوع | سند |
|---|---|
| نصب در VS2026 و ساخت حساب مدیر | [راه‌اندازی](docs/SETUP.fa.md) |
| پوشه‌ها، مسئولیت کد و گردش درخواست | [معماری](docs/ARCHITECTURE.fa.md) |
| جدول‌ها، روابط و Migration | [دیتابیس](docs/DATABASE.fa.md) |
| آدرس‌ها، فرم‌ها و دسترسی‌ها | [مسیرها](docs/ROUTES.fa.md) |
| آموزش استفاده از پنل | [راهنمای مدیر](docs/ADMIN-GUIDE.fa.md) |
| سئو، انتشار و فاز فارسی | [سئو و زبان‌ها](docs/SEO-LOCALIZATION.fa.md) |
| فایل‌ها، تنظیمات و استقرار | [استقرار و پشتیبان‌گیری](docs/DEPLOYMENT.fa.md) |
| تست، محدودیت و ارزیابی نسخه | [اعتبارسنجی](docs/VALIDATION.fa.md) |
| تصمیم‌های این گفتگو | [تصمیم‌ها](docs/DECISIONS.fa.md) |
| وضعیت و قدم بعدی | [وضعیت](docs/STATUS.fa.md) |
| ادامه توسط توسعه‌دهنده یا AI جدید | [تحویل پروژه](docs/HANDOVER.fa.md) |
| تاریخچه تغییرات | [تغییرات](CHANGELOG.md) |

## فناوری

.NET 10 LTS، EF Core 10.0.14، SQL Server، ASP.NET Core Identity و Bootstrap 5.3.8 محلی. Solution استاندارد `Asemane.sln` در VS2026 باز می‌شود. کد با MVC نوشته شده است؛ Razor Pages الگوی اصلی برنامه نیست.

## اجرا

ابتدا دستورهای کامل [SETUP](docs/SETUP.fa.md) را برای Connection String و رازهای مدیر انجام دهید؛ سپس:

```powershell
dotnet restore
dotnet tool restore
dotnet run --project src/Asemane.Web -- --bootstrap
dotnet run --project src/Asemane.Web
```

سایت: `https://localhost:7143/en` — مدیریت: `https://localhost:7143/admin`

**رمز پیش‌فرض وجود ندارد.** فرمان bootstrap صریحاً Migration و حساب مدیر را می‌سازد؛ اجرای معمولی سایت دیتابیس را تغییر نمی‌دهد.

## دامنه فاز اول

بخش عمومی Home، About، Contact، Project و Blog هرکدام Controller و View مستقل دارند. مدیریت پروژه، مقاله، صفحه، تیم، دسته‌بندی، تنظیمات عمومی، تصاویر و حساب‌های مدیر/ویرایشگر. جست‌وجو، فیلتر، مرتب‌سازی، صفحه‌بندی، حذف نرم محتوا و حذف تصویر با تأیید وجود دارد. اسلاگ‌های عوض‌شده به آدرس جدید ۳۰۱ می‌شوند.

صفحات عمومی از HTML اصلی `shokri88/Asemane-UI` در commit `5c4149ebfb028c19fea918ec638246889607205b` استفاده می‌کنند. فایل‌های CSS، JavaScript و فونت‌های قالب بدون تغییر در `wwwroot/template` نگهداری می‌شوند؛ فقط جایگاه‌های داده، لینک‌ها و متادیتای سئو پویا هستند. تغییر ظاهر یا جایگزینی رفتار قالب مجاز نیست. هیچ محتوای نمونه‌ای به‌عنوان پروژه واقعی منتشر نمی‌شود.

فایل‌ها روی دیسک سرور و بیرون `wwwroot` ذخیره می‌شوند؛ SQL فقط مشخصات و ترجمه تصویر را نگه می‌دارد. در production مسیر پایدار جدا از پوشه Publish تنظیم شود.

## بررسی

```powershell
dotnet build Asemane.sln -c Release
dotnet test tests/Asemane.Tests -c Release
dotnet ef migrations has-pending-model-changes --project src/Asemane.Web
```

تست‌های خودکار از SQLite فقط در پروژه تست استفاده می‌کنند. تست نهایی روی SQL Server و هاست مقصد، یک مرحله جداگانه است. مستندات ادعای تست انجام‌نشده ندارند.

## ارتقای تصاویر، تماس و ویرایشگر HTML

قبل از اجرای نسخه ۱۰ نوامبر، Migration `ProjectMediaRolesRichTextAndContact` را با EF اعمال کنید؛ SQL ارتقا و جزئیات در [دیتابیس](docs/DATABASE.fa.md) آمده است. نقش هر تصویر پروژه از مدیریت تصاویر تعیین می‌شود؛ نمایش در خانه با Featured است. کد پستی و نقشه از تنظیمات قابل ویرایش‌اند. متن‌های اصلی از ویرایشگر HTML محلی با پاک‌سازی سمت سرور استفاده می‌کنند؛ راهنما در [مدیریت](docs/ADMIN-GUIDE.fa.md) است.

برای نسخه جدید About، Migration `AboutStatisticsAndTeamImages` نیز لازم است. عنوان و مقدار چهار شمارنده از بخش «شمارنده‌های صفحه درباره» در تنظیمات مدیریت تغییر می‌کند. تصویر مربع هر عضو در About و یک تصویر افقی در جزئیات عضو نمایش داده می‌شوند. SQL این ارتقا در `docs/database/20261110-about-statistics-team-images.sql` است.

طبق پاسخ نهایی کاربر تعداد تصاویر عضو دو است. Migration تکمیلی `LimitTeamToTwoImages` نیز لازم است؛ داده جایگاه سوم قبلی با حفظ فایل به تصویر عمومی تبدیل می‌شود.
