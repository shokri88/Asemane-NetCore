# اعتبارسنجی نسخه اولیه

تاریخ: ۱ نوامبر ۲۰۲۶. محیط: Linux، SDK 10.0.403، Runtime 10.0.14.

## نتایج

| بررسی | نتیجه |
|---|---|
| build پروژه و Razor Viewها | موفق، بدون خطا و هشدار |
| آزمون‌های xUnit + ASP.NET TestServer | ۱۶ آزمون، همه موفق |
| EF pending model changes | بدون تغییر مدل ثبت‌نشده |
| تولید Initial Migration و SQL idempotent | موفق |
| ترجمه Query تولیدی به SQL Server و تولید SQL Identity/CMS | موفق؛ بدون اتصال زنده به SQL |
| NuGet vulnerable شامل وابستگی غیرمستقیم production | آسیب‌پذیری شناخته‌شده‌ای در فهرست فعلی گزارش نشد |
| syntax دو فایل JavaScript | node --check موفق |
| مرورگر desktop/mobile | ۵ صفحه در عرض ۱۴۴۰ و ۳۹۰؛ بدون overflow افقی کل صفحه و خطای JS |
| منوی عمومی موبایل و offcanvas پنل | بازشدن با کلیک بررسی شد |
| SQL Server واقعی، IIS و اطلاعات کسب‌وکار | در این محیط قابل اجرا نبود؛ مرحله استقرار |

یک هشدار وابستگی غیرمستقیم System.Security.Cryptography.Pkcs نسخه 9.0.11 در Restore اولیه دیده شد؛ نسخه 10.0.14 صریح ثبت شد و audit بعدی هشدار نداشت. این بررسی جایگزین به‌روزرسانی و audit دوره‌ای نیست.

## پوشش تست

- پیش‌نویس و fa غیرفعال پاسخ عمومی ندارند.
- canonical از دامنه تنظیم‌شده ساخته می‌شود؛ sitemap پیش‌نویس ندارد و hreflang فارسی ساختگی تولید نمی‌شود.
- مدیریت ناشناس به ورود هدایت می‌شود؛ POST بدون anti-forgery رد می‌شود.
- Editor اجازه کاربران/تنظیمات ندارد.
- ذخیره فرم واقعی محتوا، ریدایرکت ۳۰۱ اسلاگ قبلی و جلوگیری از بازنویسی نسخه قدیمی.
- متن script به HTML فعال تبدیل نمی‌شود.
- آپلود واقعی PNG روی دیسک، رد فایل HTML با پسوند تصویر و محرمانه‌بودن تصویر پیش‌نویس.
- رندر صفحات پنل و حذف نرم محتوا.
- ساخت دسته، رد تکراری و ذخیره تنظیمات با فیلد اختیاری خالی.
- JSON-LD معتبر، نویسنده سازمانی به‌جای شخص فرضی و تاریخ دارای timezone.
- Query/DDL مربوط به SQL Server از مدل production تولید می‌شود.
- صفحات رندرشده یک H1 و بدون id تکراری هستند.
- نرمال‌سازی اسلاگ انگلیسی/فارسی و بررسی امضای فایل.

## روش مرورگر

HTML واقعی Razor از TestServer با داده آزمایشی استخراج و CSS/JS همان پروژه در Chromium headless نمایش داده شد. صفحات dashboard، content list، edit، home و project در desktop/mobile بررسی شدند. این آزمون ظاهر و رفتار کوچک JS است؛ ادعای تست اتصال مرورگر به SQL Server production نیست. داده seed تست وارد bootstrap یا دیتابیس اصلی نمی‌شود.

## تکرار

```powershell
dotnet build Asemane.sln -c Release
dotnet test tests/Asemane.Tests -c Release --logger "trx;LogFileName=tests.trx"
dotnet tool restore
dotnet ef migrations has-pending-model-changes --project src/Asemane.Web
dotnet list src/Asemane.Web package --vulnerable --include-transitive
```

خروجی TRX تولید می‌شود اما در git ثبت نمی‌شود. GitHub Actions آن را به‌عنوان artifact نگه می‌دارد. اجرای workflow روی GitHub نتیجه مستقل دارد و باید از تب Actions مشاهده شود.

## بررسی لازم پیش از انتشار عمومی

روی SQL Server واقعی bootstrap را اجرا کنید؛ ایجاد، ویرایش، دسته، آپلود، انتشار، تغییر اسلاگ و سطح دسترسی را با محتوای واقعی بررسی کنید. سپس مسیر پایدار فایل‌ها، backup/restore، HTTPS، کلیدها، دامنه canonical و تنظیم ایندکس را روی هاست مقصد کنترل کنید. امتیاز Lighthouse و SEO رقابتی با داده واقعی هنوز محاسبه نشده است.

## نتیجه اجرای GitHub Actions پس از ثبت کد

اولین workflow روی commit `595e6e0` در [اجرای 41312924912](https://github.com/shokri88/Asemane-NetCore/actions/runs/41312924912) پیش از شروع job متوقف شد. پیام خود GitHub:

> The job was not started because your account is locked due to a billing issue.

هیچ مرحله Build یا Test روی runner اجرا نشد؛ بنابراین این نتیجه، شکست تست کد نیست و CI موفق روی GitHub نیز ادعا نمی‌شود. ۱۵ تست و Release Build در محیط توسعه موفق بوده‌اند. رفع محدودیت Billing از تنظیمات حساب مالک انجام می‌شود و تغییری در تنظیمات مالی حساب داده نشده است. پس از رفع آن، همین workflow را دوباره اجرا کنید.

## اعتبارسنجی تفکیک Controller و View

پس از تفکیک Home، About، Contact، Project و Blog، Release Build با صفر هشدار و صفر خطا و هر ۱۶ تست موفق شدند. تست جدید مالکیت مسیرها را از ActionDescriptor، وجود View کامپایل‌شده مستقل، رندر هر پنج بخش، فهرست/جزئیات پروژه و بلاگ، صفحات دیگر، تیم و ۳۰۱ مسیر قدیمی about بررسی می‌کند. نمایش تیم فقط در درباره و اطلاعات تماس فقط در تماس نیز بررسی شد. تست‌های قبلی canonical، schema، انتشار، دسترسی و اسلاگ همچنان موفق‌اند. این تغییر فقط ساختار MVC را تغییر می‌دهد و Migration جدید لازم ندارد.
