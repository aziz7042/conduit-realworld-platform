// Diese Migration fügt die Tabelle "ArticleImages" in die Datenbankstruktur ein.
// Sie enthält die Spalten: Id (Primärschlüssel), Url (Pfad zum Bild) und ArticleId (Fremdschlüssel zum Artikel).
// Außerdem wird ein Fremdschlüssel definiert, der die Bilder mit den jeweiligen Artikeln verknüpft.

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Realworlddotnet.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddArticleImages : Migration
    {
        /// <inheritdoc />
        // Methode wird beim Anwenden der Migration ausgeführt
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Tabelle "ArticleImages" erzeugen
            migrationBuilder.CreateTable(
                name: "ArticleImages",
                columns: table => new
                {
                    // Spalte für die Bild-ID, Autowert
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),

                    // Spalte für die URL des Bildes, darf nicht null sein
                    Url = table.Column<string>(type: "TEXT", nullable: false),

                    // Spalte für den Fremdschlüssel zum Artikel
                    ArticleId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    // Primärschlüssel auf der Spalte "Id"
                    table.PrimaryKey("PK_ArticleImages", x => x.Id);

                    // Fremdschlüssel-Verknüpfung zur Tabelle "Articles"
                    table.ForeignKey(
                        name: "FK_ArticleImages_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade); // Löscht Bilder automatisch, wenn Artikel gelöscht wird
                });

            // Index auf die Spalte "ArticleId" setzen, für schnellere Abfragen
            migrationBuilder.CreateIndex(
                name: "IX_ArticleImages_ArticleId",
                table: "ArticleImages",
                column: "ArticleId");
        }

        /// <inheritdoc />
        // Wird aufgerufen, wenn die Migration zurückgerollt wird
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Tabelle "ArticleImages" wird gelöscht
            migrationBuilder.DropTable(
                name: "ArticleImages");
        }
    }
}
