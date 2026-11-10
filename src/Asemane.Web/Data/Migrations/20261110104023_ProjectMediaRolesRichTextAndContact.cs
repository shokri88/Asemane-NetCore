using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Asemane.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class ProjectMediaRolesRichTextAndContact : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Phone",
                table: "Settings",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50);

            migrationBuilder.AddColumn<string>(
                name: "MapEmbedUrl",
                table: "Settings",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "Settings",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "Role",
                table: "Media",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "BodyIsHtml",
                table: "ContentTranslations",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media",
                columns: new[] { "ContentItemId", "Role" },
                unique: true,
                filter: "[ContentItemId] IS NOT NULL AND [Role] >= 1 AND [Role] <= 4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media");

            migrationBuilder.DropColumn(
                name: "MapEmbedUrl",
                table: "Settings");

            migrationBuilder.DropColumn(
                name: "PostalCode",
                table: "Settings");

            migrationBuilder.DropColumn(
                name: "Role",
                table: "Media");

            migrationBuilder.DropColumn(
                name: "BodyIsHtml",
                table: "ContentTranslations");

            migrationBuilder.AlterColumn<string>(
                name: "Phone",
                table: "Settings",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(200)",
                oldMaxLength: 200);
        }
    }
}
