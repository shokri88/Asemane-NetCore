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
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Media]') AND [c].[name] = N'IsCover');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Media] DROP CONSTRAINT ' + @var + ';');
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

