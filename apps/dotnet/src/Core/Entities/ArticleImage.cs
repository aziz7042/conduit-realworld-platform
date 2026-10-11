// Diese Klasse bildet die neue Datenbank-Tabelle "ArticleImages" ab.
// Sie speichert mehrere Bilder, die einem Artikel zugeordnet sind.
// Jedes Bild enthält einen eindeutigen Primärschlüssel (Id), die Bild-URL, einen Fremdschlüssel zum Artikel und eine Navigationseigenschaft.

namespace Realworlddotnet.Core.Entities;

public class ArticleImage
{
    // Eindeutige ID des Bildes (Primärschlüssel in der Datenbank)
    public int Id { get; set; }

    // Öffentliche URL, unter der das Bild erreichbar ist (z.B. http://localhost/uploads/abc.jpg)
    public string Url { get; set; } = string.Empty;

    // Fremdschlüssel, der das Bild mit genau einem Artikel verknüpft
    public Guid ArticleId { get; set; }

    // Navigationseigenschaft zu dem zugehörigen Artikel-Objekt (für Entity Framework)
    public Article Article { get; set; } = null!;
}
