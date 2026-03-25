using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class ProviderStatusInterview : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Address",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "Website",
                table: "Providers");

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "Providers",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "Providers");

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Providers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Website",
                table: "Providers",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
