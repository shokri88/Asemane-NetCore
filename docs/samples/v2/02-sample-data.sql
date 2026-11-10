-- Development sample data v2. Run ONLY after reset and latest migrations.
-- No accounts/passwords are created. All demo content is published with NoIndex=1.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF NOT EXISTS (SELECT 1 FROM dbo.__EFMigrationsHistory WHERE MigrationId=N'20261110150221_RemoveUntypedMedia')
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

INSERT dbo.Categories (Kind,SortOrder) VALUES (1,0);
SET @category=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES (1,@category,N'en',N'Demo Residential',N'demo-v2-residential');

INSERT dbo.Categories (Kind,SortOrder) VALUES (1,0);
SET @category=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES (1,@category,N'en',N'Demo Commercial',N'demo-v2-commercial');

INSERT dbo.Categories (Kind,SortOrder) VALUES (2,0);
SET @category=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES (2,@category,N'en',N'Demo Journal',N'demo-v2-journal');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-residential');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-1',@category,0,1,0,200,2024,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 1',N'demo-project-1',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 1.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Design Development',N'',N'Demo Project 1',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'828dcebd1d8557d089a9a4709365bf6f.jpg',N'828dcebd1d8557d089a9a4709365bf6f.jpg',N'image/jpeg',91131,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'c6ec181ec0d85419b3a52073b084668e.jpg',N'c6ec181ec0d85419b3a52073b084668e.jpg',N'image/jpeg',143469,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'f4b9f26f81d557dcace85a46e66275e5.jpg',N'f4b9f26f81d557dcace85a46e66275e5.jpg',N'image/jpeg',49939,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'19b3e617c3025aabb7612b6a195279c5.jpg',N'19b3e617c3025aabb7612b6a195279c5.jpg',N'image/jpeg',231324,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'dcb88cc6de1d5547bc487b1652c6b77b.jpg',N'dcb88cc6de1d5547bc487b1652c6b77b.jpg',N'image/jpeg',134713,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'7555ebb4942f5ff4a42eece58b37b344.jpg',N'7555ebb4942f5ff4a42eece58b37b344.jpg',N'image/jpeg',419658,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 1 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-commercial');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-2',@category,0,1,1,235,2025,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 2',N'demo-project-2',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 2.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Under Construction',N'',N'Demo Project 2',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'5cb1ce4ea9825e88864896ddc47e5ffd.jpg',N'5cb1ce4ea9825e88864896ddc47e5ffd.jpg',N'image/jpeg',143469,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'46806db928fc55038489eab9646ea109.jpg',N'46806db928fc55038489eab9646ea109.jpg',N'image/jpeg',72130,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'34b14ff871e25bb0b7e92135351e80bb.jpg',N'34b14ff871e25bb0b7e92135351e80bb.jpg',N'image/jpeg',71767,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'37ef24c80e305fddbf460ad88540a7a4.jpg',N'37ef24c80e305fddbf460ad88540a7a4.jpg',N'image/jpeg',134713,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'527a57f8a99955e5a9d62d9c3acfb938.jpg',N'527a57f8a99955e5a9d62d9c3acfb938.jpg',N'image/jpeg',419658,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'57cc10d460205c4e9439d8c819b53403.jpg',N'57cc10d460205c4e9439d8c819b53403.jpg',N'image/jpeg',142351,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 2 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-residential');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-3',@category,0,1,2,270,2026,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 3',N'demo-project-3',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 3.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Completed',N'',N'Demo Project 3',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'35845bcdb2375288b50c89f61c702808.jpg',N'35845bcdb2375288b50c89f61c702808.jpg',N'image/jpeg',72130,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'64cf43b12f14544cb3844bec88325bc9.jpg',N'64cf43b12f14544cb3844bec88325bc9.jpg',N'image/jpeg',92128,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'd205b9b2101e5bb695097b7487d938d3.jpg',N'd205b9b2101e5bb695097b7487d938d3.jpg',N'image/jpeg',46453,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'deaeffb48d25563b9d48a27b71084407.jpg',N'deaeffb48d25563b9d48a27b71084407.jpg',N'image/jpeg',419658,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'2ed61f10e54a57a6b902a55570d0e924.jpg',N'2ed61f10e54a57a6b902a55570d0e924.jpg',N'image/jpeg',142351,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'5b889b502c9158b491089030920478b6.jpg',N'5b889b502c9158b491089030920478b6.jpg',N'image/jpeg',228005,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 3 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-commercial');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-4',@category,0,1,3,305,2024,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 4',N'demo-project-4',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 4.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Design Development',N'',N'Demo Project 4',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'd67a5c70514f57609576321b878a8fb3.jpg',N'd67a5c70514f57609576321b878a8fb3.jpg',N'image/jpeg',92128,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'adeefc4cdf4b576aa86c2aacd0e1bc84.jpg',N'adeefc4cdf4b576aa86c2aacd0e1bc84.jpg',N'image/jpeg',66997,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'006842682cb253fb9bf54d1db4e29739.jpg',N'006842682cb253fb9bf54d1db4e29739.jpg',N'image/jpeg',119963,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'a50cb13c38d45b43ac3e1fb616bdadb9.jpg',N'a50cb13c38d45b43ac3e1fb616bdadb9.jpg',N'image/jpeg',142351,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'cd886a397ba757b2af4459df7beae71b.jpg',N'cd886a397ba757b2af4459df7beae71b.jpg',N'image/jpeg',228005,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'0a3026703bff54b19083a0930698ed5f.jpg',N'0a3026703bff54b19083a0930698ed5f.jpg',N'image/jpeg',208354,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 4 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-residential');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-5',@category,0,1,4,340,2025,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 5',N'demo-project-5',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 5.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Under Construction',N'',N'Demo Project 5',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'0ff01fa44a97551689edad4a0893d08b.jpg',N'0ff01fa44a97551689edad4a0893d08b.jpg',N'image/jpeg',66997,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'4a4e6b063a4a518d9c18f67b6affd993.jpg',N'4a4e6b063a4a518d9c18f67b6affd993.jpg',N'image/jpeg',164822,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'7dc9c7837b16532bbfbc16d35992e9a4.jpg',N'7dc9c7837b16532bbfbc16d35992e9a4.jpg',N'image/jpeg',43033,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'd8826eeae087514fb6ad7290375ab7bd.jpg',N'd8826eeae087514fb6ad7290375ab7bd.jpg',N'image/jpeg',228005,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'b33353dbc38b574fba3e596b27fc0385.jpg',N'b33353dbc38b574fba3e596b27fc0385.jpg',N'image/jpeg',208354,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'399379a5c33d5065b455785662bbcd6c.jpg',N'399379a5c33d5065b455785662bbcd6c.jpg',N'image/jpeg',242972,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 5 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-commercial');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-6',@category,0,1,5,375,2026,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 6',N'demo-project-6',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 6.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Completed',N'',N'Demo Project 6',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'5c6b7bdc375559c5b9a2f9688c24e81f.jpg',N'5c6b7bdc375559c5b9a2f9688c24e81f.jpg',N'image/jpeg',164822,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'746a7075f5c257b6b5b3b4a54ee5e6f5.jpg',N'746a7075f5c257b6b5b3b4a54ee5e6f5.jpg',N'image/jpeg',57990,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'c3376470e7ff511fb62b3f293a920a58.jpg',N'c3376470e7ff511fb62b3f293a920a58.jpg',N'image/jpeg',68307,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'66b672fef2d95f7585971e58ea5e98c7.jpg',N'66b672fef2d95f7585971e58ea5e98c7.jpg',N'image/jpeg',208354,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'fe96305c4ac4567587417bd71a725854.jpg',N'fe96305c4ac4567587417bd71a725854.jpg',N'image/jpeg',242972,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'0b39396fc3635a98846cf823e91f70fe.jpg',N'0b39396fc3635a98846cf823e91f70fe.jpg',N'image/jpeg',268567,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 6 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-residential');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-7',@category,0,1,6,410,2024,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 7',N'demo-project-7',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 7.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Design Development',N'',N'Demo Project 7',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'e77064259f555a6d89f19c6207cd299a.jpg',N'e77064259f555a6d89f19c6207cd299a.jpg',N'image/jpeg',57990,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'5c73e2b3663d50a6a434a5e85dccef7f.jpg',N'5c73e2b3663d50a6a434a5e85dccef7f.jpg',N'image/jpeg',96683,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'bba4cdd0cef857eba6b2b1b8f14add32.jpg',N'bba4cdd0cef857eba6b2b1b8f14add32.jpg',N'image/jpeg',65544,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'1b4eb43a101f51848d2ff82fa00486c1.jpg',N'1b4eb43a101f51848d2ff82fa00486c1.jpg',N'image/jpeg',242972,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'e231bf0a84475a32986d1b5c87cb94fa.jpg',N'e231bf0a84475a32986d1b5c87cb94fa.jpg',N'image/jpeg',268567,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'cf0c926ef6e656b4bb2fc8a2a5d84858.jpg',N'cf0c926ef6e656b4bb2fc8a2a5d84858.jpg',N'image/jpeg',156894,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 7 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-v2-commercial');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (1,N'demo-v2-project-8',@category,0,1,7,445,2025,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',1,N'Demo Project 8',N'demo-project-8',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Project 8.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'Under Construction',N'',N'Demo Project 8',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'a4f72a07fcd851019f3420f4bee45d53.jpg',N'a4f72a07fcd851019f3420f4bee45d53.jpg',N'image/jpeg',96683,1,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'2f788677a85c5f6abf1b2f262ed4fa7e.jpg',N'2f788677a85c5f6abf1b2f262ed4fa7e.jpg',N'image/jpeg',93432,2,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 2',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'46de96496e0e5444b31f89b5e02b9601.jpg',N'46de96496e0e5444b31f89b5e02b9601.jpg',N'image/jpeg',79559,3,2,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 3',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'8439edc278985a80a9783058dedb1042.jpg',N'8439edc278985a80a9783058dedb1042.jpg',N'image/jpeg',268567,4,3,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 4',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'45cd330f71a25cdc8d0ca1c0110bdb3a.jpg',N'45cd330f71a25cdc8d0ca1c0110bdb3a.jpg',N'image/jpeg',156894,5,4,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 5',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'0bd361309ad951fbb03727507782862b.jpg',N'0bd361309ad951fbb03727507782862b.jpg',N'image/jpeg',231324,5,5,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Project 8 — demo image 6',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-v2-journal');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (2,N'demo-v2-article-1',@category,0,0,8,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',2,N'Demo Article 1',N'demo-article-1',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Article 1.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Article 1',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'b30eeabcb422540b850e77ac3781a71b.jpg',N'b30eeabcb422540b850e77ac3781a71b.jpg',N'image/jpeg',65544,9,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 1 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'55fb845b54c852fcbe4f1d88688e7d4e.jpg',N'55fb845b54c852fcbe4f1d88688e7d4e.jpg',N'image/jpeg',242972,10,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 1 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-v2-journal');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (2,N'demo-v2-article-2',@category,0,0,9,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',2,N'Demo Article 2',N'demo-article-2',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Article 2.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Article 2',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'61e3d3259a3158c8a995eaa19ae3b553.jpg',N'61e3d3259a3158c8a995eaa19ae3b553.jpg',N'image/jpeg',79559,9,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 2 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'86f2f0cc08105eb4a8972fcce0e7a8c8.jpg',N'86f2f0cc08105eb4a8972fcce0e7a8c8.jpg',N'image/jpeg',268567,10,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 2 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-v2-journal');
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (2,N'demo-v2-article-3',@category,0,0,10,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',2,N'Demo Article 3',N'demo-article-3',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Article 3.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Article 3',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'72d49dc0d5255375921bb52401d3206a.jpg',N'72d49dc0d5255375921bb52401d3206a.jpg',N'image/jpeg',91750,9,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 3 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'64ee52b858aa523483f4ca185dbdb1f7.jpg',N'64ee52b858aa523483f4ca185dbdb1f7.jpg',N'image/jpeg',156894,10,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Article 3 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-1',@category,0,0,11,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 1',N'demo-member-1',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 1.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 1',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'b43c7c975d7a5d9d8901ca4c3ec4f87b.jpg',N'b43c7c975d7a5d9d8901ca4c3ec4f87b.jpg',N'image/jpeg',49939,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 1 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'2d54cb06aa78545ea50e5d572c535e95.jpg',N'2d54cb06aa78545ea50e5d572c535e95.jpg',N'image/jpeg',231324,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 1 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-2',@category,0,0,12,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 2',N'demo-member-2',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 2.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 2',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'ad59246e893958909c2eb294c77b4fdc.jpg',N'ad59246e893958909c2eb294c77b4fdc.jpg',N'image/jpeg',71767,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 2 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'8fb5e2dd7c7c5e3da3575380299ac8c6.jpg',N'8fb5e2dd7c7c5e3da3575380299ac8c6.jpg',N'image/jpeg',134713,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 2 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-3',@category,0,0,13,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 3',N'demo-member-3',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 3.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 3',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'a728504bfca25f4f84f5ef8f6d9039fe.jpg',N'a728504bfca25f4f84f5ef8f6d9039fe.jpg',N'image/jpeg',46453,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 3 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'6cca4e0efcf05b7f8f5cbb356d627306.jpg',N'6cca4e0efcf05b7f8f5cbb356d627306.jpg',N'image/jpeg',419658,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 3 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-4',@category,0,0,14,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 4',N'demo-member-4',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 4.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 4',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'5d742f5429055913bcc68eae992756e5.jpg',N'5d742f5429055913bcc68eae992756e5.jpg',N'image/jpeg',119963,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 4 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'daccfab8461755bf9ae2ac06d6dbe22c.jpg',N'daccfab8461755bf9ae2ac06d6dbe22c.jpg',N'image/jpeg',142351,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 4 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-5',@category,0,0,15,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 5',N'demo-member-5',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 5.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 5',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'c77ea39949735a338cfb66166e58b3bb.jpg',N'c77ea39949735a338cfb66166e58b3bb.jpg',N'image/jpeg',43033,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 5 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'ee5434c408535a83bb9f80fc6c02f6aa.jpg',N'ee5434c408535a83bb9f80fc6c02f6aa.jpg',N'image/jpeg',228005,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 5 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (4,N'demo-v2-team-6',@category,0,0,16,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',4,N'Demo Member 6',N'demo-member-6',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Member 6.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Member 6',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'c8faabc53d6a513dbdb9eb862a8c119f.jpg',N'c8faabc53d6a513dbdb9eb862a8c119f.jpg',N'image/jpeg',68307,6,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 6 — demo image 1',N'Demo photograph from the supplied template.');

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'9ad0d4d901b65be4b2de3aecf63d058c.jpg',N'9ad0d4d901b65be4b2de3aecf63d058c.jpg',N'image/jpeg',208354,7,1,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Member 6 — demo image 2',N'Demo photograph from the supplied template.');

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=3 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (3,N'about',@category,0,0,17,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',3,N'About',N'about',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for About.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'About',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=3 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (3,N'contact',@category,0,0,18,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',3,N'Contact',N'contact',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Contact.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Contact',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

SET @category=(SELECT CategoryId FROM dbo.CategoryTranslations WHERE Kind=3 AND Culture=N'en' AND Slug=NULL);
INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
VALUES (3,N'demo-v2-page',@category,0,0,19,NULL,NULL,@now,@now,NEWID());
SET @content=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,BodyIsHtml,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
VALUES (@content,N'en',3,N'Demo Studio Story',N'demo-studio-story',N'Development sample only. Replace with approved real content.',N'<h2>Development sample</h2><p>This is <strong>demo content</strong> for Demo Studio Story.</p><p>Replace the text and photographs before publishing a real portfolio.</p>',1,N'',N'Demo location',N'',N'',N'Demo Studio Story',N'Development sample only. Replace with approved real content.',1,1,DATEADD(day,-1,@now));

INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,Role,SortOrder,CreatedAt) VALUES (@content,N'0ab46388853958bc8e08b4eac03cb6b5.jpg',N'0ab46388853958bc8e08b4eac03cb6b5.jpg',N'image/jpeg',134713,11,0,@now);
SET @media=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption) VALUES (@media,N'en',N'Demo Studio Story — demo image 1',N'Demo photograph from the supplied template.');

 COMMIT TRANSACTION;
 SELECT Kind,COUNT(*) AS ContentCount FROM dbo.Contents GROUP BY Kind;
 SELECT Role,COUNT(*) AS ImageCount FROM dbo.Media GROUP BY Role;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
