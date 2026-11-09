-- Asemane: DEVELOPMENT SAMPLE DATA ONLY (not real portfolio/team information).
-- Select your DEVELOPMENT database in SSMS before running this file.
-- Run EF migrations / docs/database/initial.sql first. Administrator creation remains the --bootstrap workflow.
-- Existing content is never overwritten. Published demo records have NoIndex=1.
-- Run one copy at a time. Re-running is supported; do not rename the demo keys/files.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF OBJECT_ID(N'dbo.Contents',N'U') IS NULL OR OBJECT_ID(N'dbo.MediaTranslations',N'U') IS NULL
    THROW 51000, 'Apply the Asemane migrations to the selected database first.', 1;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @now datetimeoffset = SYSDATETIMEOFFSET(), @content int, @media int, @category int, @settings int;
IF NOT EXISTS (SELECT 1 FROM dbo.Settings)
    INSERT dbo.Settings (Brand,Phone,Email,InstagramUrl,Latitude,Longitude,LogoId,CompletedProjects,YearsExperience,TeamCount)
    VALUES (N'Asmane Architectural Studio',N'',N'',N'',NULL,NULL,NULL,0,0,0);
SELECT TOP (1) @settings=Id FROM dbo.Settings ORDER BY Id;
IF NOT EXISTS (SELECT 1 FROM dbo.SiteTranslation WHERE SiteSettingsId=@settings AND Culture=N'en')
    INSERT dbo.SiteTranslation (SiteSettingsId,Culture,HomeTitle,HomeDescription,Address)
    VALUES (@settings,N'en',N'Architecture and Interior Design',N'Development sample portfolio. Replace demo content before publication.',N'');

SET @category=NULL;
SELECT @category=CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential';
IF @category IS NULL BEGIN
 INSERT dbo.Categories (Kind,SortOrder) VALUES (1,900);
 SET @category=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES (1,@category,N'en',N'Residential — Demo',N'demo-residential');
END;

SET @category=NULL;
SELECT @category=CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-studio-notes';
IF @category IS NULL BEGIN
 INSERT dbo.Categories (Kind,SortOrder) VALUES (2,900);
 SET @category=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.CategoryTranslations (Kind,CategoryId,Culture,Name,Slug) VALUES (2,@category,N'en',N'Studio notes — Demo',N'demo-studio-notes');
END;

-- Demo Project 01
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-1';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-01')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-1',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,900,160,2024,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 01',N'demo-project-01',N'Development sample only. Replace with your own approved content.',N'Demo Project 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Design Development',N'',N'Demo Project 01',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'ba4151917448650f2a979bf59c3d2e48.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'ba4151917448650f2a979bf59c3d2e48.jpg',N'demo-demo-project-01-1.jpg',N'image/jpeg',250721,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 01 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'26501ce8e8448df22aa3090febb7b5d4.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'26501ce8e8448df22aa3090febb7b5d4.jpg',N'demo-demo-project-01-2.jpg',N'image/jpeg',388066,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 01 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 02
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-2';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-02')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-2',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,901,195,2025,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 02',N'demo-project-02',N'Development sample only. Replace with your own approved content.',N'Demo Project 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Under Construction',N'',N'Demo Project 02',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'd5eaca9adba02c07749d72259406f6d5.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'd5eaca9adba02c07749d72259406f6d5.jpg',N'demo-demo-project-02-1.jpg',N'image/jpeg',388066,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 02 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'e860bc3758108a816b33c25e00b5eaaf.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'e860bc3758108a816b33c25e00b5eaaf.jpg',N'demo-demo-project-02-2.jpg',N'image/jpeg',197546,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 02 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 03
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-3';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-03')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-3',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,902,230,2026,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 03',N'demo-project-03',N'Development sample only. Replace with your own approved content.',N'Demo Project 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Completed',N'',N'Demo Project 03',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'a9eb55fc75604c03ab9d658f100299a8.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'a9eb55fc75604c03ab9d658f100299a8.jpg',N'demo-demo-project-03-1.jpg',N'image/jpeg',197546,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 03 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'5ee139e2f2fc0cca65ecd44dfda34f65.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'5ee139e2f2fc0cca65ecd44dfda34f65.jpg',N'demo-demo-project-03-2.jpg',N'image/jpeg',365958,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 03 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 04
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-4';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-04')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-4',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,903,265,2024,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 04',N'demo-project-04',N'Development sample only. Replace with your own approved content.',N'Demo Project 04: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Design Development',N'',N'Demo Project 04',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 04: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'1f7d34145b524d5b0ce2ca7a95c6a474.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'1f7d34145b524d5b0ce2ca7a95c6a474.jpg',N'demo-demo-project-04-1.jpg',N'image/jpeg',365958,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 04 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'515ac73146e4c48962292dbd338c2d5d.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'515ac73146e4c48962292dbd338c2d5d.jpg',N'demo-demo-project-04-2.jpg',N'image/jpeg',216844,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 04 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 05
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-5';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-05')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-5',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,904,300,2025,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 05',N'demo-project-05',N'Development sample only. Replace with your own approved content.',N'Demo Project 05: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Under Construction',N'',N'Demo Project 05',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 05: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'00ffbe9d6fd3298688296ab6fbe57c43.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'00ffbe9d6fd3298688296ab6fbe57c43.jpg',N'demo-demo-project-05-1.jpg',N'image/jpeg',216844,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 05 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'5112de4d95696efc8eef2d9676ef8a60.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'5112de4d95696efc8eef2d9676ef8a60.jpg',N'demo-demo-project-05-2.jpg',N'image/jpeg',546942,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 05 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 06
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-6';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-06')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-6',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,905,335,2026,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 06',N'demo-project-06',N'Development sample only. Replace with your own approved content.',N'Demo Project 06: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Completed',N'',N'Demo Project 06',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 06: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'3dcd1896dc6808f430dff10d5d1ccc46.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'3dcd1896dc6808f430dff10d5d1ccc46.jpg',N'demo-demo-project-06-1.jpg',N'image/jpeg',546942,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 06 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'bac21fb7a267709dbf695f82ca91caea.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'bac21fb7a267709dbf695f82ca91caea.jpg',N'demo-demo-project-06-2.jpg',N'image/jpeg',196609,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 06 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 07
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-7';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-07')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-7',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,906,370,2024,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 07',N'demo-project-07',N'Development sample only. Replace with your own approved content.',N'Demo Project 07: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Design Development',N'',N'Demo Project 07',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 07: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'1022139a3b282c808859d40335278db3.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'1022139a3b282c808859d40335278db3.jpg',N'demo-demo-project-07-1.jpg',N'image/jpeg',196609,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 07 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'fbc55a1b11186cb143525a188022fc2e.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'fbc55a1b11186cb143525a188022fc2e.jpg',N'demo-demo-project-07-2.jpg',N'image/jpeg',349042,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 07 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Project 08
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=1 AND [Key]=N'demo-seed-v1-project-8';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-project-08')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (1,N'demo-seed-v1-project-8',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=1 AND Culture=N'en' AND Slug=N'demo-residential'),0,1,907,405,2025,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',1,N'Demo Project 08',N'demo-project-08',N'Development sample only. Replace with your own approved content.',N'Demo Project 08: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'Sample location',N'Under Construction',N'',N'Demo Project 08',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Project 08: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'8e23ea57629da7ba8fcb35c7c5937566.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'8e23ea57629da7ba8fcb35c7c5937566.jpg',N'demo-demo-project-08-1.jpg',N'image/jpeg',349042,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 08 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'370aa97b51bbac1692f0aeaf031cff15.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'370aa97b51bbac1692f0aeaf031cff15.jpg',N'demo-demo-project-08-2.jpg',N'image/jpeg',357132,0,1,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Project 08 — sample photograph 2',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Journal 01
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=2 AND [Key]=N'demo-seed-v1-article-1';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-journal-01')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (2,N'demo-seed-v1-article-1',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-studio-notes'),0,0,908,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',2,N'Demo Journal 01',N'demo-journal-01',N'Development sample only. Replace with your own approved content.',N'Demo Journal 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Journal 01',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Journal 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'103083ce79eee8eb4fc3fe9917346958.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'103083ce79eee8eb4fc3fe9917346958.jpg',N'demo-demo-journal-01-1.jpg',N'image/jpeg',357132,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Journal 01 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Journal 02
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=2 AND [Key]=N'demo-seed-v1-article-2';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-journal-02')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (2,N'demo-seed-v1-article-2',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-studio-notes'),0,0,909,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',2,N'Demo Journal 02',N'demo-journal-02',N'Development sample only. Replace with your own approved content.',N'Demo Journal 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Journal 02',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Journal 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'92f53770dad5ff111c39552b2efced63.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'92f53770dad5ff111c39552b2efced63.jpg',N'demo-demo-journal-02-1.jpg',N'image/jpeg',250721,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Journal 02 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Journal 03
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=2 AND [Key]=N'demo-seed-v1-article-3';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-journal-03')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (2,N'demo-seed-v1-article-3',(SELECT TOP (1) CategoryId FROM dbo.CategoryTranslations WHERE Kind=2 AND Culture=N'en' AND Slug=N'demo-studio-notes'),0,0,910,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',2,N'Demo Journal 03',N'demo-journal-03',N'Development sample only. Replace with your own approved content.',N'Demo Journal 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Journal 03',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Journal 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'b176dfccabb303da1c037b721f0bb1fb.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'b176dfccabb303da1c037b721f0bb1fb.jpg',N'demo-demo-journal-03-1.jpg',N'image/jpeg',388066,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Journal 03 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Team Member 01
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=4 AND [Key]=N'demo-seed-v1-team-1';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=N'demo-team-01')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (4,N'demo-seed-v1-team-1',NULL,0,0,911,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',4,N'Demo Team Member 01',N'demo-team-01',N'Development sample only. Replace with your own approved content.',N'Demo Team Member 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Team Member 01',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Team Member 01: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'0a3344694fce3865494d3c073b919efa.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'0a3344694fce3865494d3c073b919efa.jpg',N'demo-demo-team-01-1.jpg',N'image/jpeg',197546,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Team Member 01 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Team Member 02
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=4 AND [Key]=N'demo-seed-v1-team-2';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=N'demo-team-02')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (4,N'demo-seed-v1-team-2',NULL,0,0,912,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',4,N'Demo Team Member 02',N'demo-team-02',N'Development sample only. Replace with your own approved content.',N'Demo Team Member 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Team Member 02',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Team Member 02: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'f1d568b5b8112d0344d3c222f70f6a55.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'f1d568b5b8112d0344d3c222f70f6a55.jpg',N'demo-demo-team-02-1.jpg',N'image/jpeg',365958,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Team Member 02 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Team Member 03
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=4 AND [Key]=N'demo-seed-v1-team-3';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=N'demo-team-03')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (4,N'demo-seed-v1-team-3',NULL,0,0,913,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',4,N'Demo Team Member 03',N'demo-team-03',N'Development sample only. Replace with your own approved content.',N'Demo Team Member 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Team Member 03',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Team Member 03: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'd5f6f96076f8f372199514873588c43d.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'd5f6f96076f8f372199514873588c43d.jpg',N'demo-demo-team-03-1.jpg',N'image/jpeg',216844,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Team Member 03 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Demo Team Member 04
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=4 AND [Key]=N'demo-seed-v1-team-4';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=4 AND Culture=N'en' AND Slug=N'demo-team-04')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (4,N'demo-seed-v1-team-4',NULL,0,0,914,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',4,N'Demo Team Member 04',N'demo-team-04',N'Development sample only. Replace with your own approved content.',N'Demo Team Member 04: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Demo Team Member 04',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Demo Team Member 04: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'0328f8542e5404a08c94393547dbfb00.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'0328f8542e5404a08c94393547dbfb00.jpg',N'demo-demo-team-04-1.jpg',N'image/jpeg',546942,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Demo Team Member 04 — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- About
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=3 AND [Key]=N'about';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=3 AND Culture=N'en' AND Slug=N'about')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (3,N'about',NULL,0,0,915,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',3,N'About',N'about',N'Development sample only. Replace with your own approved content.',N'About: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'About',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

UPDATE dbo.ContentTranslations SET Title=N'About',Summary=N'Development sample only. Replace with your own approved content.',Body=N'About: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',MetaDescription=N'Development sample only. Replace with your own approved content.',NoIndex=1,Published=1,PublishedAt=DATEADD(day,-1,@now)
 WHERE ContentItemId=@content AND Culture=N'en' AND Body=N'' AND Summary=N'' AND Published=0 AND Slug=N'about';

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'About: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'15fc556e455e8fcc544e75356c96a8bc.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'15fc556e455e8fcc544e75356c96a8bc.jpg',N'demo-about-1.jpg',N'image/jpeg',196609,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'About — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

-- Contact
SET @content=NULL;
SELECT @content=Id FROM dbo.Contents WHERE Kind=3 AND [Key]=N'contact';
IF @content IS NULL BEGIN
 IF EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE Kind=3 AND Culture=N'en' AND Slug=N'contact')
    THROW 51001, 'A seed slug already belongs to different content. No changes committed.', 1;
 INSERT dbo.Contents (Kind,[Key],CategoryId,IsDeleted,Featured,SortOrder,Area,[Year],CreatedAt,UpdatedAt,[Version])
 VALUES (3,N'contact',NULL,0,0,916,NULL,NULL,@now,@now,NEWID());
 SET @content=CONVERT(int,SCOPE_IDENTITY());
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ContentTranslations WHERE ContentItemId=@content AND Culture=N'en')
 INSERT dbo.ContentTranslations (ContentItemId,Culture,Kind,Title,Slug,Summary,Body,Subtitle,Location,ProjectStatus,AuthorName,SeoTitle,MetaDescription,NoIndex,Published,PublishedAt)
 VALUES (@content,N'en',3,N'Contact',N'contact',N'Development sample only. Replace with your own approved content.',N'Contact: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',N'',N'',N'',N'',N'Contact',N'Development sample only. Replace with your own approved content.',1,1,DATEADD(day,-1,@now));

UPDATE dbo.ContentTranslations SET Title=N'Contact',Summary=N'Development sample only. Replace with your own approved content.',Body=N'Contact: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.',MetaDescription=N'Development sample only. Replace with your own approved content.',NoIndex=1,Published=1,PublishedAt=DATEADD(day,-1,@now)
 WHERE ContentItemId=@content AND Culture=N'en' AND Body=N'' AND Summary=N'' AND Published=0 AND Slug=N'contact';

IF EXISTS (SELECT 1 FROM dbo.ContentTranslations t JOIN dbo.Contents c ON c.Id=t.ContentItemId
 WHERE c.Id=@content AND c.IsDeleted=0 AND t.Culture=N'en' AND t.Body=N'Contact: development sample content only.

Replace this text and the sample photographs with your own approved information before publishing the real website.' AND t.NoIndex=1) BEGIN

SET @media=NULL;
SELECT @media=Id FROM dbo.Media WHERE StoredName=N'af2bf7c82d3db26c3c4415c96aca4d17.jpg';
IF @media IS NULL BEGIN
 INSERT dbo.Media (ContentItemId,StoredName,OriginalName,ContentType,Bytes,IsCover,SortOrder,CreatedAt)
 VALUES (@content,N'af2bf7c82d3db26c3c4415c96aca4d17.jpg',N'demo-contact-1.jpg',N'image/jpeg',349042,1,0,@now);
 SET @media=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.MediaTranslations (MediaAssetId,Culture,Alt,Caption)
 VALUES (@media,N'en',N'Contact — sample photograph 1',N'Development sample photograph from the supplied Asemane-UI template.');
END;

END;

COMMIT TRANSACTION;
SELECT c.Kind,t.Title,t.Slug,t.Published,t.NoIndex,COUNT(m.Id) AS ImageCount
FROM dbo.Contents c JOIN dbo.ContentTranslations t ON c.Id=t.ContentItemId
LEFT JOIN dbo.Media m ON m.ContentItemId=c.Id
WHERE c.[Key] LIKE N'demo-seed-v1-%' OR (c.[Key] IN (N'about',N'contact') AND t.NoIndex=1)
GROUP BY c.Kind,t.Title,t.Slug,t.Published,t.NoIndex ORDER BY c.Kind,t.Slug;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
