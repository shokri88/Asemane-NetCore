# مسیرها و قرارداد فرم‌ها

این فاز MVC است و REST API مستقلی ندارد. پاسخ عمومی HTML است؛ فرم‌های پنل معمولاً پس از POST موفق به GET ریدایرکت می‌شوند. همه POSTها ضد CSRF دارند، به‌جز renderer بدون تغییر وضعیت خطا.

## عمومی

| روش | مسیر | رفتار |
|---|---|---|
| GET | / | ۳۰۱ به /en |
| GET | /en | پروژه‌های منتشرشده Featured |
| GET | /en/projects | فهرست پروژه؛ category و page اختیاری |
| GET | /en/projects/{slug} | جزئیات یا ۳۰۱ از اسلاگ قبلی |
| GET | /en/journal | فهرست مقاله؛ category و page اختیاری |
| GET | /en/journal/{slug} | مقاله و schema |
| GET | /en/about | صفحه about و تیم منتشرشده |
| GET | /en/contact | متن تماس و تنظیمات استودیو |
| GET | /en/pages/{slug} | صفحه مستقل؛ about/contact به مسیر کوتاه ۳۰۱ می‌شوند |
| GET | /en/team/{slug} | معرفی عضو تیم |
| GET | /media/{id} | تصویر عمومی یا پیش‌نویس برای کاربر مجاز |
| GET | /robots.txt | وابسته به IndexingEnabled |
| GET | /sitemap.xml | آدرس‌های مجاز و منتشرشده |
| GET | /error | پاسخ ۵۰۰ عمومی |
| همه روش‌ها | /status/{code} | نمایش کد خطای ۴۰۰ تا ۵۹۹؛ هیچ تغییری در DB نمی‌دهد |

زبان نامعتبر/غیرفعال 404 می‌گیرد. صفحه جزئیات منتشرنشده 404 واقعی است. page نامعتبر و دسته ناموجود نیز 404 هستند. صفحه‌های شماره‌دار و فیلترشده noindex دارند؛ canonical فیلتر به فهرست پایه برمی‌گردد.

## مدیریت

| Controller | GET | POST | نقش |
|---|---|---|---|
| Account | Login، Denied | Login، Logout | ورود عمومی؛ خروج کاربر واردشده |
| Dashboard | Index | — | Admin/Editor |
| Content | Index(kind,q,status,sort,page)، Edit(id,kind) | Edit(ContentForm)، Delete(id,version) | Admin/Editor |
| Categories | Index، Edit(id) | Edit(CategoryForm)، Delete(id) | Admin/Editor |
| Media | Index(contentId) | Upload(contentId,file,alt)، Update(MediaForm)، Delete(id,contentId) | Admin/Editor |
| Settings | Index | Index(SettingsForm + Logo) | Admin |
| Users | Index، Create، ResetPassword(id) | Create(UserForm)، ResetPassword، ToggleLock(id) | Admin |

مسیر پایه `/admin/{controller}/{action}/{id?}` است. نوع محتوای پیش‌فرض Project؛ sort مجاز updated/title/order، status مجاز published/draft و اندازه صفحه مدیریت ۲۰ است.

## نکات قرارداد

- ContentForm صریحاً FromForm است؛ نام Area پروژه نباید با route value مربوط به Area مدیریت اشتباه گرفته شود.
- فایل با `multipart/form-data` و input نام file یا Logo ارسال می‌شود.
- شناسه والد رسانه در تمام عملیات بررسی می‌شود؛ تغییر contentId نباید رسانه محتوای دیگر را ویرایش کند.
- ReturnUrl ورود فقط با Url.IsLocalUrl پذیرفته می‌شود.
- در انتشار متن اصلی و توضیحات متا الزامی‌اند. title/slug همیشه الزامی‌اند.
- SQL unique index رقابت هم‌زمان روی slug را نیز کنترل می‌کند؛ فقط بررسی JavaScript نداریم.
