using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddCotizacionesModule : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ServiceRequests",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "EstimatedBudget",
                table: "ServiceRequests",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Lat",
                table: "ServiceRequests",
                type: "numeric(9,6)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Lng",
                table: "ServiceRequests",
                type: "numeric(9,6)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<Point>(
                name: "Location",
                table: "ServiceRequests",
                type: "geography (Point, 4326)",
                nullable: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "PreferredDate",
                table: "ServiceRequests",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "ServiceRequests",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TargetProviderId",
                table: "ServiceRequests",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "ServiceRequests",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "Available",
                table: "Providers",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "AvailableUpdatedAt",
                table: "Providers",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Cotizaciones",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ServiceRequestId = table.Column<int>(type: "integer", nullable: false),
                    ProviderId = table.Column<int>(type: "integer", nullable: false),
                    Amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    Currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    EstimatedHours = table.Column<int>(type: "integer", nullable: true),
                    ProposedDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    AcceptedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    RejectedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    RejectReason = table.Column<string>(type: "text", nullable: true),
                    CreationDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastUpdate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cotizaciones", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Cotizaciones_Providers_ProviderId",
                        column: x => x.ProviderId,
                        principalTable: "Providers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Cotizaciones_ServiceRequests_ServiceRequestId",
                        column: x => x.ServiceRequestId,
                        principalTable: "ServiceRequests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_Location",
                table: "ServiceRequests",
                column: "Location")
                .Annotation("Npgsql:IndexMethod", "GIST");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_Status_Type_TargetProviderId",
                table: "ServiceRequests",
                columns: new[] { "Status", "Type", "TargetProviderId" });

            migrationBuilder.CreateIndex(
                name: "IX_ServiceRequests_TargetProviderId",
                table: "ServiceRequests",
                column: "TargetProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_Cotizaciones_ProviderId_Status_CreationDate",
                table: "Cotizaciones",
                columns: new[] { "ProviderId", "Status", "CreationDate" });

            migrationBuilder.CreateIndex(
                name: "IX_Cotizaciones_ServiceRequestId_ProviderId",
                table: "Cotizaciones",
                columns: new[] { "ServiceRequestId", "ProviderId" },
                unique: true,
                filter: "\"IsDeleted\" = false");

            migrationBuilder.AddForeignKey(
                name: "FK_ServiceRequests_Providers_TargetProviderId",
                table: "ServiceRequests",
                column: "TargetProviderId",
                principalTable: "Providers",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ServiceRequests_Providers_TargetProviderId",
                table: "ServiceRequests");

            migrationBuilder.DropTable(
                name: "Cotizaciones");

            migrationBuilder.DropIndex(
                name: "IX_ServiceRequests_Location",
                table: "ServiceRequests");

            migrationBuilder.DropIndex(
                name: "IX_ServiceRequests_Status_Type_TargetProviderId",
                table: "ServiceRequests");

            migrationBuilder.DropIndex(
                name: "IX_ServiceRequests_TargetProviderId",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "EstimatedBudget",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Lat",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Lng",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "PreferredDate",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "TargetProviderId",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "ServiceRequests");

            migrationBuilder.DropColumn(
                name: "Available",
                table: "Providers");

            migrationBuilder.DropColumn(
                name: "AvailableUpdatedAt",
                table: "Providers");
        }
    }
}
