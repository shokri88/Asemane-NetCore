# راه‌اندازی در ویندوز و Visual Studio 2026

## پیش‌نیاز

- VS2026 با workload «ASP.NET and web development» و SDK .NET 10؛ نسخه توسعه بررسی‌شده SDK 10.0.403 است.
- SQL Server؛ محیط پیشنهادی کاربر SQL Server 2022 و Windows Authentication است.
- Git و اجازه ایجاد دیتابیس برای مرحله bootstrap. حساب اجرای روزمره production بهتر است مجوز تغییر schema نداشته باشد.
- ابزار dotnet-ef به نسخه مشخص در `dotnet-tools.json` ثبت شده؛ نیازی به تکیه به نسخه global نیست.

## دریافت

```powershell
git clone https://github.com/shokri88/Asemane-NetCore.git
cd Asemane-NetCore
dotnet --version
dotnet restore
dotnet tool restore
dotnet dev-certs https --trust
```

`Asemane.sln` را باز کنید و `Asemane.Web` را Startup Project بگذارید.

## اتصال دیتابیس

نمونه تنظیم local برای SQL Server پیش‌فرض:

```powershell
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=.;Database=Asemane;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true" --project src/Asemane.Web
```

برای named instance، نام سرور را مثل `Server=.\SQLEXPRESS` جایگزین کنید. نام دیتابیس `Asemane` است و می‌توان آن را در Connection String عوض کرد. `TrustServerCertificate=True` فقط نمونه local است؛ production گواهی معتبر SQL و تنظیم TLS صحیح لازم دارد.

## ساخت مدیر اولیه

دو مقدار نمونه زیر را با ایمیل و رمز خودتان عوض کنید. هیچ‌کدام رمز پیش‌فرض واقعی برنامه نیستند:

```powershell
dotnet user-secrets set "Bootstrap:Email" "your-admin@example.com" --project src/Asemane.Web
dotnet user-secrets set "Bootstrap:Password" "REPLACE-with-your-own-Strong!Password123" --project src/Asemane.Web
dotnet run --project src/Asemane.Web -- --bootstrap
```

رمز حداقل ۱۲ کاراکتر و شامل حرف بزرگ/کوچک انگلیسی، عدد و علامت است. فرمان ابتدا Migration را اجرا می‌کند، نقش‌های Admin و Editor می‌سازد، مدیر را ایجاد می‌کند و صفحات درباره/تماس را به‌صورت پیش‌نویس اضافه می‌کند. هیچ پروژه، مقاله، نویسنده یا آمار ساختگی منتشر نمی‌شود.

اجرای مجدد با همان ایمیل، رمز کاربر موجود را تغییر نمی‌دهد. برای تغییر رمز از پنل استفاده کنید. پس از ساخت مدیر، راز bootstrap را حذف کنید:

```powershell
dotnet user-secrets remove "Bootstrap:Password" --project src/Asemane.Web
dotnet user-secrets remove "Bootstrap:Email" --project src/Asemane.Web
```

User Secrets برای توسعه است و جایگزین سامانه امن تنظیمات production نیست.

## اجرا و تنظیم اولیه

```powershell
dotnet run --project src/Asemane.Web
```

- عمومی: `https://localhost:7143/en`
- مدیریت: `https://localhost:7143/admin`
- ورود: `/admin/account/login`

از HTTPS استفاده کنید؛ Cookie مدیریتی همیشه Secure است و روی HTTP ارسال نمی‌شود. در پنل ابتدا نام استودیو و اطلاعات تماس را تکمیل، دسته‌بندی ایجاد و محتوا ثبت کنید. برای دیده‌شدن پروژه در خانه، انتشار و گزینه نمایش در اسلایدر هر دو فعال شوند.

## خطاهای متداول

| خطا | راه‌حل |
|---|---|
| Login failed یا اتصال SQL | نام instance، فعال‌بودن SQL و دسترسی Windows کاربر را بررسی کنید. |
| Invalid object name | bootstrap یا database update هنوز اجرا نشده یا به DB دیگری وصل شده‌اید. |
| خطای SDK | VS2026 و SDK 10 را نصب و Terminal را دوباره باز کنید. |
| 413 در آپلود | محدودیت برنامه ۱۰ مگابایت درخواست و ۸ مگابایت تصویر است؛ محدودیت IIS نیز باید هماهنگ باشد. |
| ورود موفق ولی بازگشت به login | با HTTPS باز کنید؛ Cookie Secure است. |
| صفحه درباره/تماس 404 | پیش‌نویس است؛ متن و متا را تکمیل و منتشر کنید. |
| صفحه اصلی خالی از پروژه | پروژه منتشرشده و Featured وجود ندارد. |
| دسترسی فایل | مسیر Storage و مجوز خواندن/نوشتن حساب اجرا را بررسی کنید. |

## تغییر مدل بعدی

```powershell
dotnet ef migrations add MeaningfulChangeName --project src/Asemane.Web
dotnet ef database update --project src/Asemane.Web
```

در production ابتدا backup و بررسی SQL انجام شود؛ اجرای خودکار Migration در شروع وب‌سایت تعبیه نشده است.
