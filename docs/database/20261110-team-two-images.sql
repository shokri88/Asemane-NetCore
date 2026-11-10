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

