-- DESTRUCTIVE: deletes ALL application data and accounts; preserves schema and migration history.
-- Run on the selected development database. Change this exact name only if your DB has another name.
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @ExpectedDatabase sysname=N'Asemane';
IF DB_NAME()<>@ExpectedDatabase OR DB_NAME() IN (N'master',N'model',N'msdb',N'tempdb')
    THROW 51000, 'Select the intended Asemane development database; verify @ExpectedDatabase.',1;
IF OBJECT_ID(N'dbo.__EFMigrationsHistory',N'U') IS NULL
    THROW 51001, 'Apply the schema migrations first. This script resets data, not the schema.',1;
BEGIN TRY
 BEGIN TRANSACTION;
 UPDATE dbo.Settings SET LogoId=NULL;
 DELETE FROM dbo.AspNetUserTokens;
 DELETE FROM dbo.AspNetUserRoles;
 DELETE FROM dbo.AspNetUserLogins;
 DELETE FROM dbo.AspNetUserClaims;
 DELETE FROM dbo.AspNetRoleClaims;
 DELETE FROM dbo.AspNetUsers;
 DELETE FROM dbo.AspNetRoles;
 DELETE FROM dbo.MediaTranslations;
 DELETE FROM dbo.Media;
 DELETE FROM dbo.Redirects;
 DELETE FROM dbo.ContentTranslations;
 DELETE FROM dbo.Contents;
 DELETE FROM dbo.CategoryTranslations;
 DELETE FROM dbo.Categories;
 DELETE FROM dbo.SiteTranslation;
 DELETE FROM dbo.Settings;
 -- Reseed to 1 avoids ID 0 on a never-populated table (the UI uses 0 for new records).
 -- IDs in the sample script are captured with SCOPE_IDENTITY; no fixed media IDs are assumed.
 DBCC CHECKIDENT ('dbo.AspNetUserClaims', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.AspNetRoleClaims', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.MediaTranslations', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.Media', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.Redirects', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.ContentTranslations', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.Contents', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.CategoryTranslations', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.Categories', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.SiteTranslation', RESEED, 1) WITH NO_INFOMSGS;
 DBCC CHECKIDENT ('dbo.Settings', RESEED, 1) WITH NO_INFOMSGS;
 COMMIT TRANSACTION;
 SELECT N'Application data and users cleared. Migration history preserved. Apply latest migrations, then run sample data and bootstrap.' AS Result;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
