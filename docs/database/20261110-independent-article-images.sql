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

