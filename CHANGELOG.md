# تاریخچه تغییرات

## 2026-11-01 — پایه CMS فاز اول

- ایجاد ASP.NET Core MVC روی .NET 10 با EF Core SQL Server و Identity.
- اضافه‌شدن پنل Bootstrap فارسی، مدیریت محتوا/دسته/تصویر/تنظیمات و کاربران با نقش‌های Admin/Editor.
- سایت عمومی انگلیسی با طراحی الهام‌گرفته از Asemane-UI و رندر سمت سرور.
- مدل ترجمه، SEO، ریدایرکت اسلاگ و ذخیره فایل روی سرور خارج wwwroot.
- Initial Migration، SQL idempotent، تست و CI.
- مستندات فارسی معماری، اجرا، دیتابیس، مسیرها، UI، SEO، نگهداری، تصمیم‌ها و تحویل.
- بررسی و رفع تداخل مسیر زبان/admin، تداخل نام Area فرم با MVC Area، فیلد اختیاری خالی، و اعتبارسنجی خطا/متادیتا.

وضعیت دقیق تست‌ها و محدودیت‌ها در docs/VALIDATION.fa.md و docs/STATUS.fa.md ثبت شده است.

### نتیجه CI پس از ثبت

GitHub Actions به‌دلیل پیام قفل Billing حساب، job را شروع نکرد. جزئیات و لینک اجرا در docs/VALIDATION.fa.md ثبت شد؛ Build و ۱۵ تست محیط توسعه موفق‌اند.

## 2026-11-01 — تفکیک بخش‌های عمومی MVC

- حذف SiteController و Views/Site؛ Home، About، Contact، Project و Blog هرکدام Controller و View مستقل دارند.
- صفحات دیگر، تیم و خطا نیز Controller و View مخصوص دارند.
- خواندن مشترک داده و سئو به PublicContentService منتقل شد؛ سرویس هیچ View انتخاب نمی‌کند.
- Partial گالری برای اشتراک جزء بصری کوچک حفظ شد؛ View کامل هر صفحه مستقل است.
- URLهای فعلی، canonical، انتشار و ۳۰۱ حفظ شدند؛ Migration جدید لازم نیست.
- تست رندر، مالکیت مسیرها و یافتن View مستقل اضافه و مستندات معماری/مسیرها/تحویل به‌روز شد.
