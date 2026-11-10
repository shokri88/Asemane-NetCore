IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetRoles] (
        [Id] nvarchar(450) NOT NULL,
        [Name] nvarchar(256) NULL,
        [NormalizedName] nvarchar(256) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetUsers] (
        [Id] nvarchar(450) NOT NULL,
        [DisplayName] nvarchar(100) NOT NULL,
        [UserName] nvarchar(256) NULL,
        [NormalizedUserName] nvarchar(256) NULL,
        [Email] nvarchar(256) NULL,
        [NormalizedEmail] nvarchar(256) NULL,
        [EmailConfirmed] bit NOT NULL,
        [PasswordHash] nvarchar(max) NULL,
        [SecurityStamp] nvarchar(max) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [PhoneNumberConfirmed] bit NOT NULL,
        [TwoFactorEnabled] bit NOT NULL,
        [LockoutEnd] datetimeoffset NULL,
        [LockoutEnabled] bit NOT NULL,
        [AccessFailedCount] int NOT NULL,
        CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [Categories] (
        [Id] int NOT NULL IDENTITY,
        [Kind] int NOT NULL,
        [SortOrder] int NOT NULL,
        CONSTRAINT [PK_Categories] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [Settings] (
        [Id] int NOT NULL IDENTITY,
        [Brand] nvarchar(150) NOT NULL,
        [Phone] nvarchar(50) NOT NULL,
        [Email] nvarchar(150) NOT NULL,
        [InstagramUrl] nvarchar(500) NOT NULL,
        [Latitude] decimal(9,6) NULL,
        [Longitude] decimal(9,6) NULL,
        [LogoId] int NULL,
        [CompletedProjects] int NOT NULL,
        [YearsExperience] int NOT NULL,
        [TeamCount] int NOT NULL,
        CONSTRAINT [PK_Settings] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetRoleClaims] (
        [Id] int NOT NULL IDENTITY,
        [RoleId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetUserClaims] (
        [Id] int NOT NULL IDENTITY,
        [UserId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetUserLogins] (
        [LoginProvider] nvarchar(450) NOT NULL,
        [ProviderKey] nvarchar(450) NOT NULL,
        [ProviderDisplayName] nvarchar(max) NULL,
        [UserId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
        CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetUserRoles] (
        [UserId] nvarchar(450) NOT NULL,
        [RoleId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [AspNetUserTokens] (
        [UserId] nvarchar(450) NOT NULL,
        [LoginProvider] nvarchar(450) NOT NULL,
        [Name] nvarchar(450) NOT NULL,
        [Value] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [CategoryTranslations] (
        [Id] int NOT NULL IDENTITY,
        [Kind] int NOT NULL,
        [CategoryId] int NOT NULL,
        [Culture] nvarchar(10) NOT NULL,
        [Name] nvarchar(100) NOT NULL,
        [Slug] nvarchar(120) NOT NULL,
        CONSTRAINT [PK_CategoryTranslations] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_CategoryTranslations_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [Contents] (
        [Id] int NOT NULL IDENTITY,
        [Kind] int NOT NULL,
        [Key] nvarchar(80) NOT NULL,
        [CategoryId] int NULL,
        [IsDeleted] bit NOT NULL,
        [Featured] bit NOT NULL,
        [SortOrder] int NOT NULL,
        [Area] decimal(12,2) NULL,
        [Year] int NULL,
        [CreatedAt] datetimeoffset NOT NULL,
        [UpdatedAt] datetimeoffset NOT NULL,
        [Version] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_Contents] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Contents_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [SiteTranslation] (
        [Id] int NOT NULL IDENTITY,
        [SiteSettingsId] int NOT NULL,
        [Culture] nvarchar(10) NOT NULL,
        [HomeTitle] nvarchar(70) NOT NULL,
        [HomeDescription] nvarchar(170) NOT NULL,
        [Address] nvarchar(500) NOT NULL,
        CONSTRAINT [PK_SiteTranslation] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_SiteTranslation_Settings_SiteSettingsId] FOREIGN KEY ([SiteSettingsId]) REFERENCES [Settings] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [ContentTranslations] (
        [Id] int NOT NULL IDENTITY,
        [ContentItemId] int NOT NULL,
        [Culture] nvarchar(10) NOT NULL,
        [Kind] int NOT NULL,
        [Title] nvarchar(180) NOT NULL,
        [Slug] nvarchar(180) NOT NULL,
        [Summary] nvarchar(500) NOT NULL,
        [Body] nvarchar(max) NOT NULL,
        [Subtitle] nvarchar(180) NOT NULL,
        [Location] nvarchar(180) NOT NULL,
        [ProjectStatus] nvarchar(80) NOT NULL,
        [AuthorName] nvarchar(100) NOT NULL,
        [SeoTitle] nvarchar(70) NOT NULL,
        [MetaDescription] nvarchar(170) NOT NULL,
        [NoIndex] bit NOT NULL,
        [Published] bit NOT NULL,
        [PublishedAt] datetimeoffset NULL,
        CONSTRAINT [PK_ContentTranslations] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ContentTranslations_Contents_ContentItemId] FOREIGN KEY ([ContentItemId]) REFERENCES [Contents] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [Media] (
        [Id] int NOT NULL IDENTITY,
        [ContentItemId] int NULL,
        [StoredName] nvarchar(100) NOT NULL,
        [OriginalName] nvarchar(250) NOT NULL,
        [ContentType] nvarchar(50) NOT NULL,
        [Bytes] bigint NOT NULL,
        [IsCover] bit NOT NULL,
        [SortOrder] int NOT NULL,
        [CreatedAt] datetimeoffset NOT NULL,
        CONSTRAINT [PK_Media] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Media_Contents_ContentItemId] FOREIGN KEY ([ContentItemId]) REFERENCES [Contents] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [Redirects] (
        [Id] int NOT NULL IDENTITY,
        [Kind] int NOT NULL,
        [Culture] nvarchar(10) NOT NULL,
        [OldSlug] nvarchar(180) NOT NULL,
        [ContentItemId] int NOT NULL,
        CONSTRAINT [PK_Redirects] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Redirects_Contents_ContentItemId] FOREIGN KEY ([ContentItemId]) REFERENCES [Contents] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE TABLE [MediaTranslations] (
        [Id] int NOT NULL IDENTITY,
        [MediaAssetId] int NOT NULL,
        [Culture] nvarchar(10) NOT NULL,
        [Alt] nvarchar(250) NOT NULL,
        [Caption] nvarchar(300) NOT NULL,
        CONSTRAINT [PK_MediaTranslations] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_MediaTranslations_Media_MediaAssetId] FOREIGN KEY ([MediaAssetId]) REFERENCES [Media] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CategoryTranslations_CategoryId_Culture] ON [CategoryTranslations] ([CategoryId], [Culture]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CategoryTranslations_Kind_Culture_Slug] ON [CategoryTranslations] ([Kind], [Culture], [Slug]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_Contents_CategoryId] ON [Contents] ([CategoryId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_Contents_Kind_IsDeleted_SortOrder] ON [Contents] ([Kind], [IsDeleted], [SortOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_ContentTranslations_ContentItemId_Culture] ON [ContentTranslations] ([ContentItemId], [Culture]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_ContentTranslations_Kind_Culture_Slug] ON [ContentTranslations] ([Kind], [Culture], [Slug]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_Media_ContentItemId] ON [Media] ([ContentItemId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_MediaTranslations_MediaAssetId_Culture] ON [MediaTranslations] ([MediaAssetId], [Culture]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE INDEX [IX_Redirects_ContentItemId] ON [Redirects] ([ContentItemId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Redirects_Kind_Culture_OldSlug] ON [Redirects] ([Kind], [Culture], [OldSlug]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    CREATE UNIQUE INDEX [IX_SiteTranslation_SiteSettingsId_Culture] ON [SiteTranslation] ([SiteSettingsId], [Culture]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261101132657_InitialCmsAndIdentity'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261101132657_InitialCmsAndIdentity', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Settings]') AND [c].[name] = N'Phone');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Settings] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [Settings] ALTER COLUMN [Phone] nvarchar(200) NOT NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    ALTER TABLE [Settings] ADD [MapEmbedUrl] nvarchar(2000) NOT NULL DEFAULT N'';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    ALTER TABLE [Settings] ADD [PostalCode] nvarchar(30) NOT NULL DEFAULT N'';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    ALTER TABLE [Media] ADD [Role] int NOT NULL DEFAULT 0;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    ALTER TABLE [ContentTranslations] ADD [BodyIsHtml] bit NOT NULL DEFAULT CAST(0 AS bit);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Media_ContentItemId_Role] ON [Media] ([ContentItemId], [Role]) WHERE [ContentItemId] IS NOT NULL AND [Role] >= 1 AND [Role] <= 4');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110104023_ProjectMediaRolesRichTextAndContact'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261110104023_ProjectMediaRolesRichTextAndContact', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    DROP INDEX [IX_Media_ContentItemId_Role] ON [Media];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [SiteTranslation] ADD [AboutCompletedTitle] nvarchar(100) NOT NULL DEFAULT N'Complete';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [SiteTranslation] ADD [AboutConstructionTitle] nvarchar(100) NOT NULL DEFAULT N'Under Construction';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [SiteTranslation] ADD [AboutDesignTitle] nvarchar(100) NOT NULL DEFAULT N'Design Development';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [SiteTranslation] ADD [AboutTotalTitle] nvarchar(100) NOT NULL DEFAULT N'All Projects';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [Settings] ADD [AboutCompletedValue] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [Settings] ADD [AboutConstructionValue] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [Settings] ADD [AboutDesignValue] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    ALTER TABLE [Settings] ADD [AboutTotalValue] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Media_ContentItemId_Role] ON [Media] ([ContentItemId], [Role]) WHERE [ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,8)');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110115322_AboutStatisticsAndTeamImages'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261110115322_AboutStatisticsAndTeamImages', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110120325_LimitTeamToTwoImages'
)
BEGIN
    DROP INDEX [IX_Media_ContentItemId_Role] ON [Media];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110120325_LimitTeamToTwoImages'
)
BEGIN
    UPDATE [Media] SET [Role] = 0 WHERE [Role] = 8 AND [ContentItemId] IN (SELECT [Id] FROM [Contents] WHERE [Kind] = 4)
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110120325_LimitTeamToTwoImages'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Media_ContentItemId_Role] ON [Media] ([ContentItemId], [Role]) WHERE [ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7)');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110120325_LimitTeamToTwoImages'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261110120325_LimitTeamToTwoImages', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110131403_IndependentArticleImages'
)
BEGIN
    DROP INDEX [IX_Media_ContentItemId_Role] ON [Media];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110131403_IndependentArticleImages'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Media_ContentItemId_Role] ON [Media] ([ContentItemId], [Role]) WHERE [ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,9,10)');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110131403_IndependentArticleImages'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261110131403_IndependentArticleImages', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    UPDATE [Media] SET [Role] = 12, [ContentItemId] = NULL
    WHERE [Id] IN (SELECT [LogoId] FROM [Settings] WHERE [LogoId] IS NOT NULL);
    UPDATE [Media] SET [Role] = 5
    WHERE [Role] = 0 AND [ContentItemId] IN (SELECT [Id] FROM [Contents] WHERE [Kind] = 1);
    ;WITH Candidates AS (
        SELECT m.[Id],m.[ContentItemId],ROW_NUMBER() OVER(PARTITION BY m.[ContentItemId] ORDER BY m.[IsCover] DESC,m.[SortOrder],m.[Id]) AS n
        FROM [Media] m JOIN [Contents] c ON c.[Id]=m.[ContentItemId]
        WHERE m.[Role]=0 AND c.[Kind] IN (2,3,4)
    ), Slots AS (
        SELECT c.[Id] AS ContentItemId,v.[Role],ROW_NUMBER() OVER(PARTITION BY c.[Id] ORDER BY v.[Role]) AS n
        FROM [Contents] c JOIN (VALUES (2,9),(2,10),(3,11),(4,6),(4,7)) v([Kind],[Role]) ON v.[Kind]=c.[Kind]
        WHERE NOT EXISTS (SELECT 1 FROM [Media] m WHERE m.[ContentItemId]=c.[Id] AND m.[Role]=v.[Role])
    )
    UPDATE m SET [Role]=s.[Role] FROM [Media] m JOIN Candidates c ON c.[Id]=m.[Id]
    JOIN Slots s ON s.ContentItemId=c.[ContentItemId] AND s.n=c.n;
    DELETE FROM [MediaTranslations] WHERE [MediaAssetId] IN (SELECT [Id] FROM [Media] WHERE [Role]=0);
    DELETE FROM [Media] WHERE [Role]=0;
    DECLARE @role_default_constraint sysname;
    SELECT @role_default_constraint=d.[name] FROM sys.default_constraints d
    JOIN sys.columns c ON c.default_object_id=d.object_id
    WHERE c.object_id=OBJECT_ID(N'[dbo].[Media]') AND c.[name]=N'Role';
    IF @role_default_constraint IS NOT NULL
    BEGIN
        DECLARE @drop_role_default nvarchar(max)=N'ALTER TABLE [dbo].[Media] DROP CONSTRAINT '+QUOTENAME(@role_default_constraint);
        EXEC(@drop_role_default);
    END;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    DROP INDEX [IX_Media_ContentItemId_Role] ON [Media];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    DECLARE @var1 nvarchar(max);
    SELECT @var1 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Media]') AND [c].[name] = N'IsCover');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Media] DROP CONSTRAINT ' + @var1 + ';');
    ALTER TABLE [Media] DROP COLUMN [IsCover];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Media_ContentItemId_Role] ON [Media] ([ContentItemId], [Role]) WHERE [ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,9,10,11)');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    EXEC(N'ALTER TABLE [Media] ADD CONSTRAINT [CK_Media_ExplicitRole] CHECK (([Role] = 12 AND [ContentItemId] IS NULL) OR ([Role] IN (1,2,3,4,5,6,7,9,10,11) AND [ContentItemId] IS NOT NULL))');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261110150221_RemoveUntypedMedia'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261110150221_RemoveUntypedMedia', N'10.0.14');
END;

COMMIT;
GO

