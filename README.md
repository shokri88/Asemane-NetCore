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

قالب عمومی از چیدمان مینیمال `shokri88/Asemane-UI` بازپیاده‌سازی شده است؛ HTML استاتیک آن عیناً کپی نشده و کتابخانه‌های قدیمی آن به پروژه جدید منتقل نشده‌اند. هیچ محتوای نمونه‌ای به‌عنوان پروژه واقعی منتشر نمی‌شود.

فایل‌ها روی دیسک سرور و بیرون `wwwroot` ذخیره می‌شوند؛ SQL فقط مشخصات و ترجمه تصویر را نگه می‌دارد. در production مسیر پایدار جدا از پوشه Publish تنظیم شود.

## بررسی

```powershell
dotnet build Asemane.sln -c Release
dotnet test tests/Asemane.Tests -c Release
dotnet ef migrations has-pending-model-changes --project src/Asemane.Web
```

تست‌های خودکار از SQLite فقط در پروژه تست استفاده می‌کنند. تست نهایی روی SQL Server و هاست مقصد، یک مرحله جداگانه است. مستندات ادعای تست انجام‌نشده ندارند.
