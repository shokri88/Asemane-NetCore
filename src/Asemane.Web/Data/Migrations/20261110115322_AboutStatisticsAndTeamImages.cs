using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Asemane.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class AboutStatisticsAndTeamImages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media");

            migrationBuilder.AddColumn<string>(
                name: "AboutCompletedTitle",
                table: "SiteTranslation",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "Complete");

            migrationBuilder.AddColumn<string>(
                name: "AboutConstructionTitle",
                table: "SiteTranslation",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "Under Construction");

            migrationBuilder.AddColumn<string>(
                name: "AboutDesignTitle",
                table: "SiteTranslation",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "Design Development");

            migrationBuilder.AddColumn<string>(
                name: "AboutTotalTitle",
                table: "SiteTranslation",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "All Projects");

            migrationBuilder.AddColumn<int>(
                name: "AboutCompletedValue",
                table: "Settings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AboutConstructionValue",
                table: "Settings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AboutDesignValue",
                table: "Settings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AboutTotalValue",
                table: "Settings",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media",
                columns: new[] { "ContentItemId", "Role" },
                unique: true,
                filter: "[ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,8)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media");

            migrationBuilder.DropColumn(
                name: "AboutCompletedTitle",
                table: "SiteTranslation");

            migrationBuilder.DropColumn(
                name: "AboutConstructionTitle",
                table: "SiteTranslation");

            migrationBuilder.DropColumn(
                name: "AboutDesignTitle",
                table: "SiteTranslation");

            migrationBuilder.DropColumn(
                name: "AboutTotalTitle",
                table: "SiteTranslation");

            migrationBuilder.DropColumn(
                name: "AboutCompletedValue",
                table: "Settings");

            migrationBuilder.DropColumn(
                name: "AboutConstructionValue",
                table: "Settings");

            migrationBuilder.DropColumn(
                name: "AboutDesignValue",
                table: "Settings");

            migrationBuilder.DropColumn(
                name: "AboutTotalValue",
                table: "Settings");

            migrationBuilder.CreateIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media",
                columns: new[] { "ContentItemId", "Role" },
                unique: true,
                filter: "[ContentItemId] IS NOT NULL AND [Role] >= 1 AND [Role] <= 4");
        }
    }
}
