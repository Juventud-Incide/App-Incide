using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddOtpAndProviderRegistrationFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Curp",
                table: "Providers",
                type: "character varying(18)",
                maxLength: 18,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Providers",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProfessionalLicense",
                table: "Providers",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Rfc",
                table: "Providers",
                type: "character varying(13)",
                maxLength: 13,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "YearsOfExperience",
                table: "Providers",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "OtpCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    PhoneNumber = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CodeHash = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    IsConsumed = table.Column<bool>(type: "boolean", nullable: false),
                    Attempts = table.Column<int>(type: "integer", nullable: false),
                    CreationDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastUpdate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OtpCodes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProviderServiceItems",
                columns: table => new
                {
                    ProviderId = table.Column<int>(type: "integer", nullable: false),
                    ServiceItemId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProviderServiceItems", x => new { x.ProviderId, x.ServiceItemId });
                    table.ForeignKey(
                        name: "FK_ProviderServiceItems_Providers_ProviderId",
                        column: x => x.ProviderId,
                        principalTable: "Providers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProviderServiceItems_ServiceItems_ServiceItemId",
                        column: x => x.ServiceItemId,
                        principalTable: "ServiceItems",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Providers_Curp",
                table: "Providers",
                column: "Curp",
                unique: true,
                filter: "\"IsDeleted\" = false");

            migrationBuilder.CreateIndex(
                name: "IX_Providers_Rfc",
                table: "Providers",
                column: "Rfc",
                unique: true,
                filter: "\"IsDeleted\" = false");

            migrationBuilder.CreateIndex(
                name: "IX_OtpCodes_ExpiresAt",
                table: "OtpCodes",
                column: "ExpiresAt");

            migrationBuilder.CreateIndex(
                name: "IX_OtpCodes_PhoneNumber",
                table: "OtpCodes",
                column: "PhoneNumber");

            migrationBuilder.CreateIndex(
                name: "IX_ProviderServiceItems_ServiceItemId",
                table: "ProviderServiceItems",
                column: "ServiceItemId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OtpCodes");

            migrationBuilder.DropTable(
                name: "ProviderServiceItems");

            migrationBuilder.DropIndex(
                name: "IX_Providers_Curp",
                table: "Providers");

            migrationBuilder.DropIndex(
                name: "IX_Providers_Rfc",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "Curp",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "ProfessionalLicense",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "Rfc",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "YearsOfExperience",
                table: "Providers");
        }
    }
}
