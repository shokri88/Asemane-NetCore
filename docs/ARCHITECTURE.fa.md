# معماری و مسئولیت اجزا

## تصمیم اصلی

یک برنامه ASP.NET Core MVC با Viewهای Razor و Area مدیریت؛ نه Razor Pages، نه SPA و نه API جدا. HTML سمت سرور ساخته می‌شود و JavaScript فقط منوی موبایل، پیمایش گالری و رفتارهای کوچک پنل را انجام می‌دهد. این انتخاب برای سادگی توسعه، رندر قابل‌خزش و نگهداری مستقل از حساب AI است.

| مسیر | وظیفه |
|---|---|
| Program.cs | ثبت EF/Identity/سرویس‌ها، Cookie، HTTPS، امنیت پاسخ و مسیرها |
| Models/Entities.cs | موجودیت‌ها و قواعد پایه طول فیلدها |
| Data/AppDbContext.cs | روابط، ایندکس‌ها، precision و concurrency |
| Data/Migrations | تاریخچه EF برای SQL Server |
| Data/Bootstrapper.cs | راه‌اندازی صریح DB، نقش‌ها، مدیر و صفحات پایه |
| ViewModels/AdminModels.cs | داده ورودی محدود فرم‌ها و خروجی فهرست‌ها |
| ViewModels/PublicModels.cs | خروجی قابل‌فهم برای View عمومی و متادیتا |
| Areas/Admin/Controllers | CRUD و کنترل دسترسی پنل |
| Areas/Admin/Views | Bootstrap RTL، فهرست و فرم جدا، فوتر دکمه‌ها |
| Controllers/HomeController.cs + Views/Home | صفحه اصلی با Index مستقل |
| Controllers/AboutController.cs + Views/About | درباره استودیو و تیم با Index مستقل |
| Controllers/ContactController.cs + Views/Contact | تماس با Index مستقل |
| Controllers/ProjectController.cs + Views/Project | Index و Details مستقل پروژه‌ها |
| Controllers/BlogController.cs + Views/Blog | Index و Details مستقل بلاگ با URL فعلی journal |
| Controllers/PageController.cs + Views/Page | صفحات محتوایی دیگر؛ بدون مدیریت about/contact |
| Controllers/TeamController.cs + Views/Team | جزئیات اعضای تیم |
| Controllers/ErrorController.cs + Views/Error | صفحات خطا و وضعیت |
| Controllers/MediaController.cs | خواندن تصویر از دیسک با کنترل انتشار |
| Controllers/SeoController.cs | robots و sitemap زنده از DB |
| Services/FileStorage.cs | مدیریت نام و مسیر و نوشتن فایل روی سرور |
| Services/SiteService.cs | Query محتوای منتشرشده و اطلاعات مشترک layout |
| Services/PublicContentService.cs | خواندن مشترک فهرست/جزئیات، lookup ریدایرکت و ساخت داده سئو؛ بدون انتخاب View |
| Services/SeoService.cs | canonical، OG و JSON-LD |
| Services/Slugs.cs | تبدیل عنوان/اسلاگ و مسیر استاندارد هر نوع |
| Services/Languages.cs | زبان‌های فعال؛ اکنون فقط en |
| Services/SiteCultureConstraint.cs | جلوگیری از تداخل مسیر زبان با admin و media |
| Views/Shared | layout، renderer امن متن و Partial گالری |
| wwwroot/css, js | استایل‌ها و رفتارهای ساده و محلی |
| tests/Asemane.Tests | آزمون‌های واحد و یکپارچه با TestServer |

## گردش محتوا

درخواست عمومی ← Controller ← SiteService/EF ← SQL Server ← ViewModel/Entity خواندنی ← Razor ← HTML. فیلتر انتشار، زبان و حذف نرم قبل از رندر اجرا می‌شود. رندر مخفی در مرورگر جایگزین کنترل سمت سرور نیست.

ذخیره مدیریت ← Cookie/Role ← Anti-forgery ← ViewModel Validation ← بررسی اسلاگ، دسته و Version ← EF SaveChanges. JSON یا Entity دلخواه از کاربر پذیرفته نمی‌شود.

## سادگی آگاهانه

- EF DbContext مستقیماً در Controllerهای CRUD استفاده شده؛ لایه Generic Repository صرفاً برای پوشاندن EF نداریم.
- چهار نوع محتوا با `ContentKind` در یک جدول مشترک هستند؛ فرم بر اساس نوع، فیلدهای مرتبط را نشان می‌دهد.
- ردیف‌های ترجمه مستقل‌اند و فارسی بعداً به آن‌ها اضافه می‌شود.
- منوی سایت، هدر و footer مشترک‌اند؛ مشکل تکرار هدر در HTMLهای قالب حذف شده است.
- از Swiper/jQuery/Bootstrap 3 قالب قدیمی در عمومی استفاده نشده؛ گالری با JS کوچک و پیمایش native ساخته شده است.
- Body یک زیرمجموعه ساده متن ساختاریافته است: پاراگراف، H2، H3 و فهرست. HTML خام ذخیره‌شده اجرا نمی‌شود.

## ویرایش هم‌زمان

ContentItem.Version یک Guid و concurrency token است. فرم مقدار قبلی را می‌فرستد؛ اگر رکورد تغییر کرده باشد، ذخیره رد می‌شود. هنگام رد، کاربر باید صفحه را مجدداً باز کند و تغییرات را تطبیق دهد. این ویژگی فعلاً برای محتواست، نه برای تمام فرم‌های تنظیمات و دسته‌ها.

## مدیریت خطا

در production صفحه عمومی خطا جزئیات exception را نشان نمی‌دهد. وضعیت 404 واقعاً 404 است. خطای اعتبارسنجی کنار فرم/در خلاصه فرم نشان داده می‌شود. لاگ استاندارد ASP.NET Core استفاده شده؛ سرویس ارسال خطا یا پنل ErrorLogs جداگانه هنوز نداریم.

## قاعده تفکیک صفحه‌ها

Home، About، Contact، Project و Blog باید Controller و پوشه View مستقل داشته باشند. Controller جامع Site و View عمومی همه‌منظوره حذف شده است. هر بخش می‌تواند بدون دست‌زدن به View بخش دیگر تغییر کند. فقط layout، گالری و renderer متن مشترک‌اند؛ PublicContentService صرفاً داده می‌خواند و ActionResult یا نام View برنمی‌گرداند.

آدرس‌های موجود حفظ شده‌اند: ProjectController از projects و BlogController از journal استفاده می‌کند. این تغییر نیاز به Migration یا ریدایرکت آدرس عمومی جدید ندارد.
