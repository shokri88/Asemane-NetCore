# تنظیمات، استقرار و نگهداری

## مرز تنظیمات

تنظیمات فنی در فایل/متغیر محیطی: Connection String، دامنه canonical، فعال‌بودن ایندکس، Storage، DataProtection و AllowedHosts. تنظیمات محتوایی در پنل: برند، لوگو، تماس، آدرس، آمار و متای خانه. رمز و اطلاعات اتصال واقعی در git ممنوع است.

| کلید | کاربرد |
|---|---|
| ConnectionStrings:DefaultConnection | اتصال SQL Server |
| Site:BaseUrl | origin اصلی برای canonical و sitemap |
| Site:IndexingEnabled | پیش‌فرض false برای جلوگیری از خزش محیط آماده‌سازی |
| Storage:RootPath | مسیر دیسک؛ نسبی به ContentRoot یا مطلق |
| Storage:MaxFileBytes | پیش‌فرض 8388608؛ UI/پیام‌ها بر اساس ۸ مگابایت‌اند |
| DataProtection:KeysPath | کلیدهای ماندگار Cookie و token |
| AllowedHosts | دامنه‌های مجاز؛ production مقدار واقعی داشته باشد |
| Bootstrap:Email/Password | فقط فرمان bootstrap؛ بعد از ایجاد مدیر حذف شود |

برای متغیر محیطی `:` را با `__` جایگزین کنید. مثلاً `Storage__RootPath`.

## ذخیره فایل

مسیر پیش‌فرض توسعه `App_Data/Uploads` و مسیر کلیدها `App_Data/Keys` است. هر دو gitignore شده‌اند. در production مثال:

```text
Storage__RootPath=D:\AsemaneData\Uploads
DataProtection__KeysPath=D:\AsemaneData\Keys
```

این مسیرها خارج از پوشه Publish و خارج از wwwroot باشند. به حساب App Pool فقط دسترسی لازم خواندن/نوشتن بدهید. از ارائه مستقیم این پوشه به‌عنوان virtual directory خودداری کنید؛ رسانه باید از Controller با بررسی انتشار خوانده شود. کلیدها برای خواندن عمومی نیستند. استفاده از محل ثابت به‌تنهایی رمزنگاری کلیدهای DataProtection در حالت سکون ایجاد نمی‌کند؛ در production از ACL و قابلیت حفاظت با Certificate/DPAPI متناسب با هاست استفاده کنید.

## آپلود و محدودیت

نام UUID تولید می‌شود؛ نام اصلی مسیر ذخیره را تعیین نمی‌کند. پسوند و امضای هدر JPEG/PNG/WebP بررسی می‌شود، اندازه درخواست/فایل محدود و SVG/HTML رد می‌شود. این اعتبارسنجی هدر جایگزین رمزگشایی کامل تصویر، اسکن بدافزار یا بهینه‌سازی تصویر نیست. محتوای فایل با MIME تعیین‌شده برنامه و nosniff سرو می‌شود. Cache تصویر no-store است تا لغو انتشار با کش عمومی طولانی تداخل نداشته باشد؛ بهینه‌سازی cache/نسخه تصویر می‌تواند بعداً طراحی شود.

## IIS

1. .NET 10 Hosting Bundle و IIS ASP.NET Core Module را نصب و IIS را restart کنید.
2. گواهی HTTPS معتبر و binding دامنه تنظیم شود. App Pool روی No Managed Code باشد.
3. با `dotnet publish src/Asemane.Web -c Release -o publish` خروجی بگیرید؛ فقط خروجی را Deploy کنید.
4. Connection String و سایر تنظیمات production را خارج مخزن وارد کنید. AllowedHosts را با دامنه تنظیم کنید.
5. پوشه Uploads/Keys پایدار با مجوز حساب App Pool ایجاد کنید.
6. backup بگیرید؛ SQL Migration را بررسی و با حساب مناسب اعمال کنید. مدیر اولیه را با فرمان صریح bootstrap و متغیرهای موقت ایجاد کنید.
7. قبل از روشن‌کردن ایندکس، ورود، آپلود، انتشار و canonical را روی هاست تست کنید.
8. پس از انتشار محتوا و تأیید URL، IndexingEnabled را فعال و سایت‌مپ را به Search Console معرفی کنید.

برای reverse proxy جدا از IIS، ForwardedHeaders باید فقط برای proxyهای شناخته‌شده تنظیم شود؛ اعتماد عمومی به X-Forwarded-* اضافه نشده است. App باید scheme واقعی HTTPS را ببیند. در چند سرور، ذخیره محلی و کلیدها باید مشترک یا هماهنگ شوند؛ طرح فعلی single-server است.

## پشتیبان‌گیری

سه بخش باید با هم حفظ شوند: SQL Server backup، پوشه Uploads و تنظیمات امن/کلیدهای DataProtection. صرف git backup محتوای سایت نیست. زمان backup دیتابیس و فایل‌ها نزدیک باشد و بازیابی واقعی در محیط جدا آزمایش شود. rollback کد به‌تنهایی rollback schema نیست؛ قبل از Migration از DB نسخه پشتیبان بگیرید.

## احراز هویت

Identity با Cookie امن، HttpOnly، SameSite=Lax و ضد CSRF. پس از ۵ ورود اشتباه حساب ۱۵ دقیقه قفل می‌شود. اعتبار security stamp نشست هر یک دقیقه بازبینی می‌شود. ثبت‌نام عمومی، JWT، ایمیل بازیابی، MFA و ارسال پیامک در فاز اول اضافه نشده‌اند. تغییر رمز/غیرفعال‌سازی ویرایشگر از پنل مدیر انجام می‌شود. رمز پیش‌فرض و راز سخت‌کدشده وجود ندارد.
