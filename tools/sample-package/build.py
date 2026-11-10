"""Generate matching explicit-role development SQL and local image ZIP. Never executes SQL."""
import argparse,hashlib,json,zipfile,uuid
from pathlib import Path
from PIL import Image,ImageOps

def literal(value):
    if value is None:return 'NULL'
    if isinstance(value,bool):return '1' if value else '0'
    if isinstance(value,int):return str(value)
    return "N'"+str(value).replace("'","''")+"'"
def main():
    p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);p.add_argument('--template',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    uploads=a.output/'App_Data/Uploads';uploads.mkdir(parents=True,exist_ok=True)
    migrations=sorted((a.repo/'src/Asemane.Web/Data/Migrations').glob('*_RemoveUntypedMedia.cs'));assert len(migrations)==1;required=migrations[0].stem
    photos=sorted((a.template/'img/carousel-showcase').glob('*.jpg'));assert photos
    categories=[{'kind':1,'slug':'demo-v2-residential','name':'Demo Residential'},{'kind':1,'slug':'demo-v2-commercial','name':'Demo Commercial'},{'kind':2,'slug':'demo-v2-journal','name':'Demo Journal'}]
    contents=[]
    def content(kind,key,slug,title,roles,index):
        images=[]
        for order,role in enumerate(roles):
            size=(600,900) if role in (1,2) else (600,600) if role in (3,6,9) else (1440,810)
            name=uuid.uuid5(uuid.NAMESPACE_URL,'asemane-demo-v2/'+key+'/'+str(role)+'/'+str(order)).hex+'.jpg'
            image=Image.open(photos[(index+order)%len(photos)]).convert('RGB');image=ImageOps.fit(image,size,method=Image.Resampling.LANCZOS);image.save(uploads/name,format='JPEG',quality=84)
            data=(uploads/name).read_bytes();images.append({'role':role,'name':name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'width':size[0],'height':size[1],'order':order,'alt':title+' — demo image '+str(order+1)})
        contents.append({'kind':kind,'key':key,'slug':slug,'title':title,'summary':'Development sample only. Replace with approved real content.','body':'<h2>Development sample</h2><p>This is <strong>demo content</strong> for '+title+'.</p><p>Replace the text and photographs before publishing a real portfolio.</p>','category':('demo-v2-residential' if index%2==0 else 'demo-v2-commercial') if kind==1 else 'demo-v2-journal' if kind==2 else None,'featured':kind==1,'area':200+index*35 if kind==1 else None,'year':2024+index%3 if kind==1 else None,'status':['Design Development','Under Construction','Completed'][index%3] if kind==1 else '', 'images':images})
    for i in range(8):content(1,'demo-v2-project-'+str(i+1),'demo-project-'+str(i+1),'Demo Project '+str(i+1),[1,2,3,4,5,5],i)
    for i in range(3):content(2,'demo-v2-article-'+str(i+1),'demo-article-'+str(i+1),'Demo Article '+str(i+1),[9,10],i+8)
    for i in range(6):content(4,'demo-v2-team-'+str(i+1),'demo-member-'+str(i+1),'Demo Member '+str(i+1),[6,7],i+11)
    content(3,'about','about','About',[],20);content(3,'contact','contact','Contact',[],21);content(3,'demo-v2-page','demo-studio-story','Demo Studio Story',[11],22)
    manifest={'requiredMigration':required,'categories':categories,'contents':contents,'developmentOnly':True,'noIndex':True};(a.output/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    sql=[f'''-- Development sample data v2. Run ONLY after reset and latest migrations.
-- No accounts/passwords are created. All demo content is published with NoIndex=1.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF NOT EXISTS (SELECT 1 FROM dbo.__EFMigrationsHistory WHERE MigrationId={literal(required)})
 THROW 51002,'Apply the latest RemoveUntypedMedia migration before this sample.',1;
IF EXISTS (SELECT 1 FROM dbo.Contents) OR EXISTS (SELECT 1 FROM dbo.Settings) OR EXISTS (SELECT 1 FROM dbo.Categories) OR EXISTS (SELECT 1 FROM dbo.Media)
 THROW 51003,'Target must be empty. This sample never overwrites existing content. Run reset-data first.',1;
BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @now datetimeoffset=TODATETIMEOFFSET(SYSUTCDATETIME(),'+00:00'), @settings int, @content int, @category int, @media int;
 INSERT dbo.Settings (Brand,Phone,Email,InstagramUrl,PostalCode,MapEmbedUrl,Latitude,Longitude,LogoId,CompletedProjects,YearsExperience,TeamCount,AboutTotalValue,AboutDesignValue,AboutConstructionValue,AboutCompletedValue)
 VALUES (N'Asmane Demo Studio',N'0000000000',N'demo@example.test',N'',N'00000-00000',N'',NULL,NULL,NULL,0,0,0,8,3,6,2026);
 SET @settings=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.SiteTranslation (SiteSettingsId,Culture,HomeTitle,HomeDescription,Address,AboutTotalTitle,AboutDesignTitle,AboutConstructionTitle,AboutCompletedTitle)
 VALUES (@settings,N'en',N'Demo Architecture Studio',N'Development sample only.',N'Development sample address',N'Demo projects',N'Demo articles',N'Demo members',N'Demo year');
''']
    for c in categories:
        sql.append(f"INSERT dbo.Categories (Kind,SortOrder) VALUES ({c['kind']},0);\nSET @category=CONVERT(int,SCOPE_IDENTITY());\nINSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES ({c['kind']},@category,N'en',{literal(c['name'])},{literal(c['slug'])});\n")
    for i,c in enumerate(contents):
        sql.append(f"SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind={c['kind']} AND Culture=N'en' AND Slug={literal(c['category'])});\nINSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])\nVALUES ({c['kind']},{literal(c['key'])},@category,0,{literal(c['featured'])},{i},{literal(c['area'])},{literal(c['year'])},@now,@now,NEWID());\nSET @content=CONVERT(int,SCOPE_IDENTITY());\nINSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)\nVALUES (@content,N'en',{c['kind']},{literal(c['title'])},{literal(c['slug'])},{literal(c['summary'])},{literal(c['body'])},1,N'',N'Demo location',{literal(c['status'])},N'',{literal(c['title'])},{literal(c['summary'])},1,1,DATEADD(day,-1,@now));\n")
        for image in c['images']:
            sql.append(f"INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,{literal(image['name'])},{literal(image['name'])},N'image/jpeg',{image['bytes']},{image['role']},{image['order']},@now);\nSET @media=CONVERT(int,SCOPE_IDENTITY());\nINSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',{literal(image['alt'])},N'Demo photograph from the supplied template.');\n")
    sql.append(''' COMMIT TRANSACTION;
 SELECT Kind,COUNT(*) AS ContentCount FROM dbo.Contents GROUP BY Kind;
 SELECT Role,COUNT(*) AS ImageCount FROM dbo.Media GROUP BY Role;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
''');(a.output/'02-sample-data.sql').write_text('\n'.join(sql),encoding='utf-8-sig')
    readme='''بسته داده نمونه نسخه ۲ — فقط برای توسعه

۱. از دیتابیس مهم backup بگیرید. 00-reset-data.sql تمام محتوا و کاربران را حذف می‌کند، ولی schema و Migration history حفظ می‌شود. در SSMS دیتابیس درست را انتخاب کنید؛ نام پیش‌فرض Asemane در @ExpectedDatabase قابل تغییر است. برنامه را هنگام عملیات متوقف کنید.
۲. آخرین کد main را بگیرید و dotnet ef database update --project src/Asemane.Web را اجرا کنید. اگر ابزار EF در دسترس نیست، 01-current-schema.sql شامل تمام Migrationهای idempotent است؛ پس از reset روی همان DB اجرا کنید. برای دیتابیس خالی ابتدا schema را بسازید و نیازی به reset نیست.
۳. فقط پوشه App_Data/Uploads داخل ZIP را در src/Asemane.Web استخراج کنید. برای Storage:RootPath سفارشی، محتویات Uploads را در همان مسیر بریزید. پوشه قبلی Uploads را بیرون مسیر اجرا backup/منتقل کنید؛ فایل‌های قدیمی دیتابیس جدید را پر نمی‌کنند. App_Data/Keys را حذف یا جایگزین نکنید.
۴. 02-sample-data.sql را در همان DB اجرا کنید. اسکریپت روی DB دارای محتوا متوقف می‌شود؛ برای تکرار، اول reset کنید. هیچ محتوای قبلی را بازنویسی نمی‌کند. نام فایل‌ها عوض نشود.
۵. چون reset حساب‌ها را حذف کرده، مدیر را با دستور dotnet run --project src/Asemane.Web -- --bootstrap و Bootstrap:Email/Password شخصی طبق SETUP بسازید؛ هیچ رمز یا حساب پیش‌فرض در ZIP نیست. سپس سایت را اجرا کنید.

۸ پروژه، ۳ مقاله، ۶ عضو، درباره، تماس و یک صفحه عمومی؛ ۶۷ تصویر نقش‌دار با نسبت درست. هر پروژه دو تصویر عمودی خانه، یک مربع، یک بنر و دو تصویر گالری دارد. هر مقاله مربع و بنر جدا و هر عضو مربع و افقی جدا دارد. صفحه عمومی یک بنر دارد. تمام داده‌ها نمونه و NoIndex هستند. Site:IndexingEnabled توسعه خاموش بماند. قالب اصلی تغییر نکرده است.

گزینه عمومی/قدیمی و IsCover در نسخه جدید وجود ندارند؛ نقش همه تصاویر صریح است. عکس‌ها از قالب ارسالی شما انتخاب و فقط برای این نمونه crop شده‌اند. اطلاعات استودیو/محتوا ساختگی و برای توسعه‌اند.

SQL در این محیط روی SQL Server واقعی اجرا نشده است؛ نحو آن با parser رسمی Microsoft ScriptDom و schema/رابطه نقش‌ها و داده fixture و نام/حجم/هش/ابعاد تصاویر بررسی شده‌اند. reset هیچ فایل فیزیکی روی دیسک را پاک نمی‌کند.
''';(a.output/'README.fa.txt').write_text(readme)
    for source in ['00-reset-data.sql','01-current-schema.sql']:
        path=a.repo/'docs/samples/v2'/source
        if path.exists():(a.output/source).write_bytes(path.read_bytes())
    (a.repo/'docs/samples/v2/02-sample-data.sql').write_bytes((a.output/'02-sample-data.sql').read_bytes());(a.repo/'docs/samples/v2/manifest.json').write_bytes((a.output/'manifest.json').read_bytes());(a.repo/'docs/samples/v2/README.fa.txt').write_text(readme)
    with zipfile.ZipFile(a.output/'asemane-demo-v2.zip','w',zipfile.ZIP_DEFLATED) as z:
        for f in sorted(uploads.glob('*.jpg')):z.write(f,'App_Data/Uploads/'+f.name)
        for f in ['00-reset-data.sql','01-current-schema.sql','02-sample-data.sql','manifest.json','README.fa.txt']:
            if (a.output/f).exists():z.write(a.output/f,f)
    with zipfile.ZipFile(a.output/'asemane-demo-v2.zip') as z:
        assert z.testzip() is None
        for c in contents:
            for image in c['images']:
                data=z.read('App_Data/Uploads/'+image['name']);assert len(data)==image['bytes'] and hashlib.sha256(data).hexdigest()==image['sha256']
                with Image.open(uploads/image['name']) as im:assert list(im.size)==[image['width'],image['height']];im.verify()
    count=sum(len(c['images']) for c in contents);assert count==67
    print(f'Validated {len(contents)} content records and {count} images; ZIP CRCs, dimensions, names, bytes and SHA256 verified.')
if __name__=='__main__':main()
