using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Asemane.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class IndependentArticleImages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media");

            migrationBuilder.CreateIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media",
                columns: new[] { "ContentItemId", "Role" },
                unique: true,
                filter: "[ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7,9,10)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media");

            migrationBuilder.CreateIndex(
                name: "IX_Media_ContentItemId_Role",
                table: "Media",
                columns: new[] { "ContentItemId", "Role" },
                unique: true,
                filter: "[ContentItemId] IS NOT NULL AND [Role] IN (1,2,3,4,6,7)");
        }
    }
}
