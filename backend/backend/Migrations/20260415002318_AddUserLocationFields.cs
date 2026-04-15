using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddUserLocationFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "LastLat",
                table: "Users",
                type: "decimal(9,6)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "LastLng",
                table: "Users",
                type: "decimal(9,6)",
                nullable: true);

            migrationBuilder.AddColumn<Point>(
                name: "Location",
                table: "Users",
                type: "geography (Point, 4326)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "LocationUpdatedAt",
                table: "Users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Location",
                table: "Users",
                column: "Location")
                .Annotation("Npgsql:IndexMethod", "GIST");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_Location",
                table: "Users");

            migrationBuilder.DropColumn(name: "LastLat",            table: "Users");
            migrationBuilder.DropColumn(name: "LastLng",            table: "Users");
            migrationBuilder.DropColumn(name: "Location",           table: "Users");
            migrationBuilder.DropColumn(name: "LocationUpdatedAt",  table: "Users");
        }
    }
}
