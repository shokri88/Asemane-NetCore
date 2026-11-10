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

