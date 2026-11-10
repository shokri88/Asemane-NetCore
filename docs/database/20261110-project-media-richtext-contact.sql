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

